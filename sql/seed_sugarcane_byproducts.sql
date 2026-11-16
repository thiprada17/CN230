SET search_path TO core, catalog, process, production, lci, impact, public;
-- Sugarcane co-products: bagasse, molasses and filter cake
-- Source: Makul, N. & Sua-iam, G. (2016), Journal of Cleaner Production,
-- "Characteristics and utilization of sugarcane filter cake waste
-- in the production of lightweight foamed concrete".
-- DOI: https://doi.org/10.1016/j.jclepro.2016.02.111
--
-- Reference mass balance per 1,000 kg harvested sugarcane:
-- Harvesting/cleaning: 1,000 = 824 factory cane + 94 field waste
--                       + 82 cleaning waste.
-- Milling: 824 factory cane = 104 sugar + 430 liquid waste
--          + 231 bagasse + 26 molasses + 33 filter cake.
-- The paper presents a secondary industry-level synthesis.
-- Period represented by the underlying Thailand data: 2004-2013.
-- No exact production year or environmental impact is assigned.

BEGIN;

-- 1. Reference location.
INSERT INTO location (province, district, country)
SELECT
    'Thailand (national sugarcane industry reference)',
    NULL,
    'Thailand'
WHERE NOT EXISTS (
    SELECT 1
    FROM location
    WHERE province = 'Thailand (national sugarcane industry reference)'
      AND country = 'Thailand'
);

-- 2. Source record.
INSERT INTO data_source (
    organization_name,
    document_name,
    publication_year,
    reference_url,
    access_date
)
SELECT
    'Natt Makul and Gritsada Sua-iam',
    'Characteristics and utilization of sugarcane filter cake waste in the production of lightweight foamed concrete',
    2016,
    'https://doi.org/10.1016/j.jclepro.2016.02.111',
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM data_source
    WHERE document_name =
      'Characteristics and utilization of sugarcane filter cake waste in the production of lightweight foamed concrete'
      AND publication_year = 2016
);

-- 3. Co-product records.
INSERT INTO product (product_name, category_id, description, unit_id)
SELECT v.product_name, c.category_id, v.description, u.unit_id
FROM (
    VALUES
      ('Bagasse',
       'Sugarcane milling co-product; reported mass is 231 kg per 1,000 kg harvested sugarcane.'),
      ('Molasses',
       'Sugarcane milling co-product; reported mass is 26 kg per 1,000 kg harvested sugarcane.'),
      ('Filter cake',
       'Raw sugarcane filter cake (press mud), before any further treatment; 33 kg per 1,000 kg harvested sugarcane.')
) AS v(product_name, description)
JOIN product_category c
  ON c.category_name = 'Sugarcane and sugar products'
JOIN unit u
  ON u.unit_symbol = 'kg'
WHERE NOT EXISTS (
    SELECT 1
    FROM product p
    WHERE p.product_name = v.product_name
      AND p.category_id = c.category_id
);

-- 4. One 1,000 kg reference batch of harvested sugarcane.
INSERT INTO production_batch (
    product_id,
    production_date,
    production_quantity,
    unit_id,
    location_id,
    production_year,
    area_ha
)
SELECT
    p.product_id,
    NULL,
    1000,
    u.unit_id,
    l.location_id,
    NULL,
    NULL
FROM product p
JOIN unit u ON u.unit_symbol = 'kg'
JOIN location l
  ON l.province = 'Thailand (national sugarcane industry reference)'
 AND l.country = 'Thailand'
WHERE p.product_name = 'Sugarcane'
  AND NOT EXISTS (
      SELECT 1
      FROM production_batch b
      WHERE b.product_id = p.product_id
        AND b.location_id = l.location_id
        AND b.production_quantity = 1000
        AND b.unit_id = u.unit_id
        AND b.production_year IS NULL
        AND b.area_ha IS NULL
  );

-- 5. Two-stage reference process.
INSERT INTO process (process_name, description)
SELECT
    'Sugarcane harvesting, cleaning and milling (Makul & Sua-iam 2016)',
    'Two-stage national industry reference mass balance per 1,000 kg harvested sugarcane. Stage 1 covers harvesting and cleaning; Stage 2 covers factory milling and co-product generation.'
WHERE NOT EXISTS (
    SELECT 1
    FROM process
    WHERE process_name =
      'Sugarcane harvesting, cleaning and milling (Makul & Sua-iam 2016)'
);

INSERT INTO process_step (
    process_id,
    step_name,
    step_order,
    description
)
SELECT p.process_id, v.step_name, v.step_order, v.description
FROM process p
CROSS JOIN (
    VALUES
      (1,
       'Harvesting and cleaning',
       'Per 1,000 kg harvested sugarcane: 824 kg is delivered to the factory, 94 kg remains as field waste, and 82 kg is separated during cleaning.'),
      (2,
       'Sugar milling and co-product generation',
       'Per 824 kg sugarcane delivered to the factory: 104 kg sugar, 430 kg liquid waste, 231 kg bagasse, 26 kg molasses, and 33 kg filter cake.')
) AS v(step_order, step_name, description)
WHERE p.process_name =
  'Sugarcane harvesting, cleaning and milling (Makul & Sua-iam 2016)'
  AND NOT EXISTS (
      SELECT 1
      FROM process_step ps
      WHERE ps.process_id = p.process_id
        AND ps.step_order = v.step_order
  );

-- 6. Flows. Product-linked flows are used for sugarcane, sugar and co-products.
-- Generic waste flows are not assigned a product record.
INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT
    v.flow_name,
    v.flow_type,
    p.product_id,
    u.unit_id
FROM (
    VALUES
      ('Harvested sugarcane (Makul & Sua-iam 2016 reference)', 'INPUT', 'Sugarcane'),
      ('Sugarcane delivered to factory (Makul & Sua-iam 2016 reference)', 'OUTPUT', 'Sugarcane'),
      ('Sugarcane received by mill (Makul & Sua-iam 2016 reference)', 'INPUT', 'Sugarcane'),
      ('Sugarcane field waste (Makul & Sua-iam 2016 reference)', 'OUTPUT', NULL),
      ('Sugarcane cleaning waste (Makul & Sua-iam 2016 reference)', 'OUTPUT', NULL),
      ('Sugar (Makul & Sua-iam 2016 reference)', 'OUTPUT', 'Sugar'),
      ('Liquid waste from sugar milling (Makul & Sua-iam 2016 reference)', 'OUTPUT', NULL),
      ('Bagasse (Makul & Sua-iam 2016 reference)', 'OUTPUT', 'Bagasse'),
      ('Molasses (Makul & Sua-iam 2016 reference)', 'OUTPUT', 'Molasses'),
      ('Filter cake (Makul & Sua-iam 2016 reference)', 'OUTPUT', 'Filter cake')
) AS v(flow_name, flow_type, product_name)
JOIN unit u ON u.unit_symbol = 'kg'
LEFT JOIN product p ON p.product_name = v.product_name
WHERE NOT EXISTS (
    SELECT 1
    FROM flow f
    WHERE f.flow_name = v.flow_name
      AND f.product_id IS NOT DISTINCT FROM p.product_id
);

-- 7. Attach the two stages to the reference batch.
INSERT INTO batch_process (
    batch_id,
    step_id,
    execution_order,
    location_id
)
SELECT
    b.batch_id,
    ps.step_id,
    ps.step_order,
    l.location_id
FROM production_batch b
JOIN product prod ON prod.product_id = b.product_id
JOIN location l ON l.location_id = b.location_id
JOIN process p
  ON p.process_name =
     'Sugarcane harvesting, cleaning and milling (Makul & Sua-iam 2016)'
JOIN process_step ps ON ps.process_id = p.process_id
WHERE prod.product_name = 'Sugarcane'
  AND b.production_quantity = 1000
  AND b.production_year IS NULL
  AND l.province = 'Thailand (national sugarcane industry reference)'
  AND NOT EXISTS (
      SELECT 1
      FROM batch_process bp
      WHERE bp.batch_id = b.batch_id
        AND bp.execution_order = ps.step_order
  );

-- 8. Exchanges. All values use the source's 2004-2013 reference period.
-- Stage 1 mass balance: 1,000 = 824 + 94 + 82 kg.
-- Stage 2 mass balance: 824 = 104 + 430 + 231 + 26 + 33 kg.
INSERT INTO lci_exchange (
    batch_process_id,
    flow_id,
    exchange_type,
    amount,
    unit_id,
    source_id,
    data_year,
    data_period_start,
    data_period_end
)
SELECT
    bp.batch_process_id,
    f.flow_id,
    v.exchange_type,
    v.amount,
    u.unit_id,
    ds.source_id,
    NULL,
    2004,
    2013
FROM (
    VALUES
      (1, 'Harvested sugarcane (Makul & Sua-iam 2016 reference)', 'INPUT', 1000::numeric),
      (1, 'Sugarcane delivered to factory (Makul & Sua-iam 2016 reference)', 'OUTPUT', 824::numeric),
      (1, 'Sugarcane field waste (Makul & Sua-iam 2016 reference)', 'OUTPUT', 94::numeric),
      (1, 'Sugarcane cleaning waste (Makul & Sua-iam 2016 reference)', 'OUTPUT', 82::numeric),
      (2, 'Sugarcane received by mill (Makul & Sua-iam 2016 reference)', 'INPUT', 824::numeric),
      (2, 'Sugar (Makul & Sua-iam 2016 reference)', 'OUTPUT', 104::numeric),
      (2, 'Liquid waste from sugar milling (Makul & Sua-iam 2016 reference)', 'OUTPUT', 430::numeric),
      (2, 'Bagasse (Makul & Sua-iam 2016 reference)', 'OUTPUT', 231::numeric),
      (2, 'Molasses (Makul & Sua-iam 2016 reference)', 'OUTPUT', 26::numeric),
      (2, 'Filter cake (Makul & Sua-iam 2016 reference)', 'OUTPUT', 33::numeric)
) AS v(step_order, flow_name, exchange_type, amount)
JOIN process p
  ON p.process_name =
     'Sugarcane harvesting, cleaning and milling (Makul & Sua-iam 2016)'
JOIN process_step ps
  ON ps.process_id = p.process_id
 AND ps.step_order = v.step_order
JOIN batch_process bp ON bp.step_id = ps.step_id
JOIN production_batch b ON b.batch_id = bp.batch_id
JOIN product prod ON prod.product_id = b.product_id
JOIN location l ON l.location_id = b.location_id
JOIN flow f ON f.flow_name = v.flow_name
JOIN unit u ON u.unit_symbol = 'kg'
JOIN data_source ds
  ON ds.document_name =
     'Characteristics and utilization of sugarcane filter cake waste in the production of lightweight foamed concrete'
 AND ds.publication_year = 2016
WHERE prod.product_name = 'Sugarcane'
  AND b.production_quantity = 1000
  AND l.province = 'Thailand (national sugarcane industry reference)'
  AND NOT EXISTS (
      SELECT 1
      FROM lci_exchange e
      WHERE e.batch_process_id = bp.batch_process_id
        AND e.flow_id = f.flow_id
        AND e.exchange_type = v.exchange_type
        AND e.amount = v.amount
        AND e.source_id = ds.source_id
        AND e.data_year IS NULL
        AND e.data_period_start = 2004
        AND e.data_period_end = 2013
  );

COMMIT;

