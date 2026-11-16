import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import pg from 'pg';

const { Pool } = pg;
pg.types.setTypeParser(1082, (value) => value);
const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER || 'agri_admin',
  password: process.env.DB_PASSWORD || 'agri_admin_password',
  database: process.env.DB_NAME || 'agri_lci',
  options: '-c search_path=core,catalog,process,production,lci,impact,public',
  max: 10,
  idleTimeoutMillis: 30_000,
});

const titleCase = (value = '') => value
  .toLowerCase()
  .replace(/(^|[_\s])\w/g, (letter) => letter.toUpperCase());

function toLocation(row) {
  return {
    location_id: row.location_id,
    province: row.province || 'Unknown province',
    district: row.district || '',
    country: row.country,
    latitude: row.latitude === null ? null : Number(row.latitude),
    longitude: row.longitude === null ? null : Number(row.longitude),
  };
}

async function loadProductRecord(productId) {
  const { rows: productRows } = await pool.query(
    `SELECT p.*, c.category_name AS category, u.unit_symbol
     FROM product p
     JOIN product_category c ON c.category_id = p.category_id
     JOIN unit u ON u.unit_id = p.unit_id
     WHERE p.product_id = $1`,
    [productId],
  );
  const product = productRows[0];
  if (!product) return null;

  const [batchResult, processResult, stepsResult, flowResult, exchangeResult,
    impactResult, sourceResult, supplierResult] = await Promise.all([
    pool.query(
      `SELECT b.*, COALESCE(b.production_date, make_date(b.production_year, 1, 1)) AS display_date,
              l.province, l.district, l.country, l.latitude, l.longitude
       FROM production_batch b
       JOIN location l ON l.location_id = b.location_id
       WHERE b.product_id = $1
       ORDER BY b.production_year DESC NULLS LAST, b.batch_id`,
      [productId],
    ),
    pool.query(
      `SELECT DISTINCT p.*
       FROM process p
       JOIN process_step ps ON ps.process_id = p.process_id
       JOIN batch_process bp ON bp.step_id = ps.step_id
       JOIN production_batch b ON b.batch_id = bp.batch_id
       WHERE b.product_id = $1
       ORDER BY p.process_id`,
      [productId],
    ),
    pool.query(
      `SELECT ps.*
       FROM process_step ps
       WHERE ps.process_id IN (
         SELECT DISTINCT linked_step.process_id
         FROM process_step linked_step
         JOIN batch_process bp ON bp.step_id = linked_step.step_id
         JOIN production_batch b ON b.batch_id = bp.batch_id
         WHERE b.product_id = $1
       )
       ORDER BY ps.step_order`,
      [productId],
    ),
    pool.query(
      `SELECT DISTINCT f.*
       FROM flow f
       JOIN lci_exchange e ON e.flow_id = f.flow_id
       JOIN batch_process bp ON bp.batch_process_id = e.batch_process_id
       JOIN production_batch b ON b.batch_id = bp.batch_id
       WHERE b.product_id = $1
       ORDER BY f.flow_id`,
      [productId],
    ),
    pool.query(
      `SELECT e.*, bp.batch_id, ps.process_id,
              u.unit_symbol, u.conversion_factor_to_base,
              base_unit.unit_symbol AS base_unit_symbol
       FROM lci_exchange e
       JOIN batch_process bp ON bp.batch_process_id = e.batch_process_id
       JOIN process_step ps ON ps.step_id = bp.step_id
       JOIN unit u ON u.unit_id = e.unit_id
       LEFT JOIN unit base_unit ON base_unit.unit_id = u.base_unit_id
       JOIN production_batch b ON b.batch_id = bp.batch_id
       WHERE b.product_id = $1
       ORDER BY bp.batch_id, e.exchange_id`,
      [productId],
    ),
    pool.query(
      `SELECT i.*, bp.batch_id, ps.process_id
       FROM environment_impact i
       JOIN batch_process bp ON bp.batch_process_id = i.batch_process_id
       JOIN process_step ps ON ps.step_id = bp.step_id
       JOIN production_batch b ON b.batch_id = bp.batch_id
       WHERE b.product_id = $1
       ORDER BY bp.batch_id, i.impact_id`,
      [productId],
    ),
    pool.query(
      `SELECT DISTINCT ds.*
       FROM data_source ds
       WHERE ds.source_id IN (
         SELECT e.source_id
         FROM lci_exchange e
         JOIN batch_process bp ON bp.batch_process_id = e.batch_process_id
         JOIN production_batch b ON b.batch_id = bp.batch_id
         WHERE b.product_id = $1
         UNION
         SELECT i.source_id
         FROM environment_impact i
         JOIN batch_process bp ON bp.batch_process_id = i.batch_process_id
         JOIN production_batch b ON b.batch_id = bp.batch_id
         WHERE b.product_id = $1
         UNION
         SELECT si.source_id
         FROM study_impact si
         WHERE si.product_id = $1
         UNION
         SELECT ms.source_id
         FROM material_supplier ms
         JOIN flow f ON f.material_id = ms.material_id
         JOIN lci_exchange e ON e.flow_id = f.flow_id
         JOIN batch_process bp ON bp.batch_process_id = e.batch_process_id
         JOIN production_batch b ON b.batch_id = bp.batch_id
         WHERE b.product_id = $1
       )
       ORDER BY ds.publication_year, ds.source_id`,
      [productId],
    ),
    pool.query(
      `SELECT DISTINCT s.*
       FROM supplier s
       JOIN material_supplier ms ON ms.supplier_id = s.supplier_id
       JOIN flow f ON f.material_id = ms.material_id
       JOIN lci_exchange e ON e.flow_id = f.flow_id
       JOIN batch_process bp ON bp.batch_process_id = e.batch_process_id
       JOIN production_batch b ON b.batch_id = bp.batch_id
       WHERE b.product_id = $1
       ORDER BY s.supplier_id
       LIMIT 1`,
      [productId],
    ),
  ]);

  const batches = batchResult.rows.map((row) => {
    const process = processResult.rows[0];
    return {
      batch_id: row.batch_id,
      product_id: row.product_id,
      process_id: process?.process_id || 0,
      production_date: row.display_date?.toISOString?.().slice(0, 10) || String(row.display_date || ''),
      production_year: row.production_year,
      production_quantity: Number(row.production_quantity),
      unit_id: row.unit_id,
      location_id: row.location_id,
      location: toLocation(row),
      area_ha: row.area_ha === null ? null : Number(row.area_ha),
    };
  });
  const primaryLocation = batches[0]?.location || {
    location_id: 0,
    province: 'Unknown province',
    district: '',
    country: 'Thailand',
    latitude: null,
    longitude: null,
  };
  const processRow = processResult.rows[0];
  const process = processRow ? {
    process_id: processRow.process_id,
    process_name: processRow.process_name,
    description: processRow.description || '',
    location_id: primaryLocation.location_id,
    unit_id: product.unit_id,
  } : {
    process_id: 0,
    process_name: 'Production process not specified',
    description: '',
    location_id: primaryLocation.location_id,
    unit_id: product.unit_id,
  };
  const steps = stepsResult.rows.map((row) => ({
    step_id: row.step_id,
    process_id: row.process_id,
    step_name: row.step_name,
    step_order: row.step_order,
    description: row.description || '',
  }));
  const flows = flowResult.rows.map((row) => ({
    flow_id: row.flow_id,
    flow_name: row.flow_name,
    flow_type: titleCase(row.flow_type),
    material_id: row.material_id,
    product_id: row.product_id,
    unit_id: row.unit_id,
    description: titleCase(row.flow_type),
  }));
  const exchanges = exchangeResult.rows.map((row) => ({
    exchange_id: row.exchange_id,
    batch_process_id: row.batch_process_id,
    process_id: row.process_id,
    batch_id: row.batch_id,
    flow_id: row.flow_id,
    exchange_type: titleCase(row.exchange_type),
    amount: Number(row.amount),
    unit_id: row.unit_id,
    unit_symbol: row.unit_symbol,
    base_unit_symbol: row.base_unit_symbol,
    conversion_factor_to_base: Number(row.conversion_factor_to_base),
    source_id: row.source_id,
    data_year: row.data_year,
  }));
  const impacts = impactResult.rows.map((row) => ({
    impact_id: row.impact_id,
    batch_process_id: row.batch_process_id,
    process_id: row.process_id,
    batch_id: row.batch_id,
    impact_type: titleCase(row.impact_type),
    impact_amount: Number(row.impact_amount),
    unit_id: row.unit_id,
    source_id: row.source_id,
    data_year: row.data_year,
  }));
  const sources = sourceResult.rows.map((row) => ({
    source_id: row.source_id,
    organization_name: row.organization_name,
    document_name: row.document_name,
    publication_year: row.publication_year,
    reference_url: row.reference_url,
    access_date: row.access_date || null,
  }));
  const supplierRow = supplierResult.rows[0];
  const supplier = supplierRow ? {
    supplier_id: supplierRow.supplier_id,
    supplier_name: supplierRow.supplier_name,
    location_id: supplierRow.location_id,
    supplier_type: supplierRow.supplier_type || '',
    contact_info: supplierRow.contact_info || '',
  } : {
    supplier_id: 0,
    supplier_name: 'Not specified in source data',
    location_id: primaryLocation.location_id,
    supplier_type: '',
    contact_info: '',
  };

  return {
    product_id: product.product_id,
    product_name: product.product_name,
    category_id: product.category_id,
    category: product.category,
    description: product.description || '',
    unit_id: product.unit_id,
    functionalUnit: `1 ${product.unit_symbol}`,
    location: primaryLocation,
    supplier,
    process,
    steps,
    batches,
    flows,
    exchanges,
    impacts,
    sources: sources.length ? sources : [{
      source_id: 0,
      organization_name: 'Source not specified',
      document_name: 'No citation linked to exchanges',
      publication_year: 0,
      reference_url: '',
      access_date: '',
    }],
    accent: '#FFE59A',
    glyph: '🌾',
  };
}

app.get('/api/health', async (_request, response) => {
  try {
    await pool.query('SELECT 1');
    response.json({ status: 'ok', database: 'connected' });
  } catch {
    response.status(503).json({ status: 'error', database: 'unavailable' });
  }
});

app.get('/api/dashboard/summary', async (_request, response, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT COUNT(DISTINCT p.product_id)::int AS total_products,
              COALESCE(SUM(e.amount) FILTER (WHERE e.exchange_type = 'INPUT'), 0) AS total_input,
              COALESCE(SUM(e.amount) FILTER (WHERE e.exchange_type = 'OUTPUT' AND f.product_id IS NOT NULL), 0) AS total_yield,
              COALESCE((SELECT SUM(i.impact_amount) FROM environment_impact i), 0) AS total_ghg
       FROM product p
       LEFT JOIN production_batch b ON b.product_id = p.product_id
       LEFT JOIN batch_process bp ON bp.batch_id = b.batch_id
       LEFT JOIN lci_exchange e ON e.batch_process_id = bp.batch_process_id
       LEFT JOIN flow f ON f.flow_id = e.flow_id`,
    );
    const row = rows[0];
    response.json({
      totalProducts: row.total_products,
      totalInput: Number(row.total_input),
      totalYield: Number(row.total_yield),
      totalGhg: Number(row.total_ghg),
    });
  } catch (error) {
    next(error);
  }
});

app.get('/api/products', async (_request, response, next) => {
  try {
    const { rows } = await pool.query('SELECT product_id FROM product ORDER BY product_id');
    const products = await Promise.all(rows.map((row) => loadProductRecord(row.product_id)));
    response.json(products.filter(Boolean));
  } catch (error) {
    next(error);
  }
});

app.get('/api/products/:id/lci', async (request, response, next) => {
  try {
    const product = await loadProductRecord(Number(request.params.id));
    if (!product) {
      response.status(404).json({ error: 'Product not found' });
      return;
    }
    response.json(product);
  } catch (error) {
    next(error);
  }
});

app.get('/api/batches', async (request, response, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT b.*, COALESCE(b.production_date, make_date(b.production_year, 1, 1)) AS display_date,
              l.province, l.district, l.country, l.latitude, l.longitude
       FROM production_batch b
       JOIN location l ON l.location_id = b.location_id
       WHERE ($1::int IS NULL OR b.product_id = $1)
       ORDER BY b.production_year DESC NULLS LAST, b.batch_id`,
      [request.query.product_id || null],
    );
    response.json(rows);
  } catch (error) {
    next(error);
  }
});

app.use((error, _request, response, _next) => {
  console.error(error);
  response.status(500).json({ error: 'Internal server error' });
});

const port = Number(process.env.PORT || 3001);
app.listen(port, () => console.log(`Agri LCI API listening on ${port}`));
