SET search_path TO core, catalog, process, production, lci, impact, public;
-- Sugarcane cultivation: Nawapanan et al. (2022), Table 2, Unit Process 1.
-- Functional unit: 1 hectare of sugarcane cultivation.
-- Data collection period: 2016-2019 (not a single production year).
-- The reported yield of 58 t/ha is converted to 58,000 kg/ha.
-- Source: https://doi.org/10.3390/su14020918

BEGIN;

INSERT INTO product_category (category_name, description)
VALUES (
    'Sugarcane and sugar products',
    'Sugarcane cultivation and sugar-industry products'
)
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO product (product_name, category_id, description, unit_id)
SELECT
    'Sugarcane',
    pc.category_id,
    'Harvested sugarcane; yield reported as 58 tonnes per hectare and converted to 58,000 kg per hectare.',
    u.unit_id
FROM product_category pc
CROSS JOIN unit u
WHERE pc.category_name = 'Sugarcane and sugar products'
  AND u.unit_symbol = 'kg'
  AND NOT EXISTS (
      SELECT 1 FROM product p WHERE p.product_name = 'Sugarcane'
  );

INSERT INTO location (province, country)
SELECT
    'Thailand (15-factory contract-farmer aggregate)',
    'Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM location
    WHERE province = 'Thailand (15-factory contract-farmer aggregate)'
      AND country = 'Thailand'
);

INSERT INTO data_source (
    organization_name, document_name, publication_year,
    reference_url, access_date
)
SELECT
    'Nawapanan et al.',
    'Green GDP Indicator with Application to Life Cycle of Sugar Industry in Thailand',
    2022,
    'https://doi.org/10.3390/su14020918',
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM data_source
    WHERE document_name =
      'Green GDP Indicator with Application to Life Cycle of Sugar Industry in Thailand'
);

INSERT INTO process (process_name, description)
SELECT
    'Sugarcane cultivation (Nawapanan et al. 2022)',
    'Aggregated cultivation inventory from contract farmers of 15 sugar factories, representing approximately 60% of Thailand sugar factory capacity. The study reviewed data from 2016 to 2019. Inventory values are reported per hectare.'
WHERE NOT EXISTS (
    SELECT 1 FROM process
    WHERE process_name = 'Sugarcane cultivation (Nawapanan et al. 2022)'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT
    p.process_id,
    'Sugarcane cultivation (1 hectare)',
    1,
    'Unit Process 1, Table 2. Inventory values are reported per hectare; data collection period 2016-2019.'
FROM process p
WHERE p.process_name = 'Sugarcane cultivation (Nawapanan et al. 2022)'
  AND NOT EXISTS (
      SELECT 1 FROM process_step ps
      WHERE ps.process_id = p.process_id
        AND ps.step_order = 1
  );

INSERT INTO production_batch (
    product_id, production_quantity, unit_id,
    location_id, production_year, area_ha
)
SELECT
    p.product_id,
    58000,
    u.unit_id,
    l.location_id,
    NULL,
    1
FROM product p
CROSS JOIN unit u
CROSS JOIN location l
WHERE p.product_name = 'Sugarcane'
  AND u.unit_symbol = 'kg'
  AND l.province = 'Thailand (15-factory contract-farmer aggregate)'
  AND l.country = 'Thailand'
  AND NOT EXISTS (
      SELECT 1 FROM production_batch b
      WHERE b.product_id = p.product_id
        AND b.location_id = l.location_id
        AND b.production_quantity = 58000
        AND b.unit_id = u.unit_id
        AND b.area_ha = 1
        AND b.production_year IS NULL
  );

INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT
    b.batch_id,
    ps.step_id,
    1,
    b.location_id
FROM production_batch b
JOIN product p ON p.product_id = b.product_id
JOIN process pr
  ON pr.process_name = 'Sugarcane cultivation (Nawapanan et al. 2022)'
JOIN process_step ps ON ps.process_id = pr.process_id AND ps.step_order = 1
WHERE p.product_name = 'Sugarcane'
  AND b.production_quantity = 58000
  AND b.area_ha = 1
  AND b.production_year IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM batch_process bp
      WHERE bp.batch_id = b.batch_id
        AND bp.step_id = ps.step_id
  );

-- Reuse existing diesel and NPK 15-15-15 flows.
-- Add source-specific flows for aggregated pesticides, water, and emissions.

INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT 'Pesticides (aggregate)', 'INPUT', u.unit_id
FROM unit u
WHERE u.unit_symbol = 'kg'
  AND NOT EXISTS (
      SELECT 1 FROM flow f
      WHERE f.flow_name = 'Pesticides (aggregate)'
        AND f.flow_type = 'INPUT'
        AND f.unit_id = u.unit_id
  );

INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT 'Water use (reported aggregate)', 'INPUT', u.unit_id
FROM unit u
WHERE u.unit_symbol = 'L'
  AND NOT EXISTS (
      SELECT 1 FROM flow f
      WHERE f.flow_name = 'Water use (reported aggregate)'
        AND f.flow_type = 'INPUT'
        AND f.unit_id = u.unit_id
  );

INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT 'Carbon dioxide (sugarcane cultivation)', 'EMISSION', u.unit_id
FROM unit u
WHERE u.unit_symbol = 'kg'
  AND NOT EXISTS (
      SELECT 1 FROM flow f
      WHERE f.flow_name = 'Carbon dioxide (sugarcane cultivation)'
        AND f.flow_type = 'EMISSION'
        AND f.unit_id = u.unit_id
  );

INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT 'Nitrous oxide (sugarcane cultivation)', 'EMISSION', u.unit_id
FROM unit u
WHERE u.unit_symbol = 'kg'
  AND NOT EXISTS (
      SELECT 1 FROM flow f
      WHERE f.flow_name = 'Nitrous oxide (sugarcane cultivation)'
        AND f.flow_type = 'EMISSION'
        AND f.unit_id = u.unit_id
  );

-- All exchanges use the documented data collection period, not an invented single year.

INSERT INTO lci_exchange (
    batch_process_id, flow_id, exchange_type, amount,
    unit_id, source_id, data_year, data_period_start, data_period_end
)
SELECT
    bp.batch_process_id,
    f.flow_id,
    v.exchange_type,
    v.amount,
    u.unit_id,
    ds.source_id,
    NULL,
    2016,
    2019
FROM batch_process bp
JOIN production_batch b ON b.batch_id = bp.batch_id
JOIN product p ON p.product_id = b.product_id
JOIN process_step ps ON ps.step_id = bp.step_id
JOIN process pr ON pr.process_id = ps.process_id
JOIN data_source ds
  ON ds.document_name =
     'Green GDP Indicator with Application to Life Cycle of Sugar Industry in Thailand'
CROSS JOIN (
    VALUES
      ('Diesel', 'INPUT', 56.0, 'L'),
      ('NPK fertilizer (15-15-15)', 'INPUT', 312.0, 'kg'),
      ('Pesticides (aggregate)', 'INPUT', 2.06, 'kg'),
      ('Water use (reported aggregate)', 'INPUT', 43750.0, 'L'),
      ('Carbon dioxide (sugarcane cultivation)', 'OUTPUT', 22.56, 'kg'),
      ('Nitrous oxide (sugarcane cultivation)', 'OUTPUT', 0.12, 'kg')
) AS v(flow_name, exchange_type, amount, unit_symbol)
JOIN flow f
  ON f.flow_name = v.flow_name
 AND f.unit_id = (SELECT unit_id FROM unit WHERE unit_symbol = v.unit_symbol)
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE p.product_name = 'Sugarcane'
  AND pr.process_name = 'Sugarcane cultivation (Nawapanan et al. 2022)'
  AND NOT EXISTS (
      SELECT 1 FROM lci_exchange e
      WHERE e.batch_process_id = bp.batch_process_id
        AND e.flow_id = f.flow_id
        AND e.source_id = ds.source_id
  );

COMMIT;

