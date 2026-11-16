SET search_path TO core, catalog, process, production, lci, impact, public;
-- Sugarcane completion: transportation and sugar production
-- Source: Nawapanan, Kongboon & Sampattagul (2022), Sustainability 14(2), 918.
-- Data period: 2016-2019. No exact production year is assigned.
-- Transportation values are scaled from the reported per-tonne FU
-- to the existing 58-tonne sugarcane batch.
-- Sugar production values retain the Table 2 FU of 1 kg sugar.
-- Table 2 reports transport diesel 6.90 L/t, while prose reports 2.30 L/t.
-- The Table 2 value is used; the discrepancy is documented here.

BEGIN;

-- 1. Add flows required by transportation and sugar production.
INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT v.flow_name, v.flow_type, u.unit_id
FROM (VALUES
    ('Carbon dioxide (sugarcane transportation)', 'EMISSION', 'kg'),
    ('Nitrous oxide (sugarcane transportation)', 'EMISSION', 'kg'),
    ('Methane (sugarcane transportation)', 'EMISSION', 'kg'),
    ('Sugarcane tops and leaves', 'OUTPUT', 'kg'),
    ('Diesel (sugar production)', 'INPUT', 'kg'),
    ('LPG (sugar production)', 'INPUT', 'kg'),
    ('Fuel oil (sugar production)', 'INPUT', 'kg'),
    ('Chemicals (sugar production)', 'INPUT', 'kg'),
    ('Water use (sugar production)', 'INPUT', 'm3'),
    ('Total suspended particulates (sugar production)', 'EMISSION', 'kg'),
    ('Hydrogen chloride (sugar production)', 'EMISSION', 'kg'),
    ('Carbon monoxide (sugar production)', 'EMISSION', 'kg'),
    ('Sulfur dioxide (sugar production)', 'EMISSION', 'kg'),
    ('Nitrogen oxides (sugar production)', 'EMISSION', 'kg'),
    ('NMVOC (sugar production)', 'EMISSION', 'kg'),
    ('Carbon dioxide (sugar production)', 'EMISSION', 'kg'),
    ('Nitrous oxide (sugar production)', 'EMISSION', 'kg'),
    ('Methane (sugar production)', 'EMISSION', 'kg'),
    ('Total dissolved solids (sugar production)', 'WATER_EMISSION', 'kg'),
    ('Suspended solids (sugar production)', 'WATER_EMISSION', 'kg'),
    ('Chemical oxygen demand (sugar production)', 'WATER_EMISSION', 'kg'),
    ('Biochemical oxygen demand (sugar production)', 'WATER_EMISSION', 'kg')
) AS v(flow_name, flow_type, unit_symbol)
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE NOT EXISTS (
    SELECT 1 FROM flow f WHERE f.flow_name = v.flow_name
);

-- 2. Create transportation process and step.
INSERT INTO process (process_name, description)
SELECT
    'Sugarcane transportation (Nawapanan et al. 2022)',
    'Transportation inventory from Table 2, reported per tonne of sugarcane. Diesel discrepancy: Table 2 reports 6.90 L/t while article prose reports 2.30 L/t; Table 2 value is used.'
WHERE NOT EXISTS (
    SELECT 1 FROM process
    WHERE process_name = 'Sugarcane transportation (Nawapanan et al. 2022)'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT
    p.process_id,
    'Transportation of 58 tonnes of sugarcane',
    1,
    'Table 2 values per tonne multiplied by the existing 58-tonne sugarcane batch. Study data period 2016-2019.'
FROM process p
WHERE p.process_name = 'Sugarcane transportation (Nawapanan et al. 2022)'
  AND NOT EXISTS (
      SELECT 1 FROM process_step ps
      WHERE ps.process_id = p.process_id AND ps.step_order = 1
  );

-- 3. Link transportation to the existing sugarcane batch.
INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT
    b.batch_id,
    ps.step_id,
    2,
    b.location_id
FROM production_batch b
JOIN product pr ON pr.product_id = b.product_id
JOIN process p
  ON p.process_name = 'Sugarcane cultivation (Nawapanan et al. 2022)'
JOIN process_step cultivation_step
  ON cultivation_step.process_id = p.process_id
JOIN batch_process cultivation_bp
  ON cultivation_bp.batch_id = b.batch_id
 AND cultivation_bp.step_id = cultivation_step.step_id
JOIN process transport
  ON transport.process_name = 'Sugarcane transportation (Nawapanan et al. 2022)'
JOIN process_step ps
  ON ps.process_id = transport.process_id AND ps.step_order = 1
WHERE pr.product_name = 'Sugarcane'
  AND b.production_quantity = 58000
  AND NOT EXISTS (
      SELECT 1 FROM batch_process existing
      WHERE existing.batch_id = b.batch_id
        AND existing.step_id = ps.step_id
  );

-- 4. Add transportation exchanges, scaled to 58 tonnes.
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
FROM process p
JOIN process_step ps ON ps.process_id = p.process_id
JOIN batch_process bp ON bp.step_id = ps.step_id
JOIN production_batch b ON b.batch_id = bp.batch_id
JOIN product pr ON pr.product_id = b.product_id
JOIN data_source ds
  ON ds.document_name ILIKE '%Green GDP Indicator with Application to Life Cycle of Sugar Industry in Thailand%'
JOIN (VALUES
    ('Diesel', 'INPUT', 400.2::numeric, 'L'),
    ('Carbon dioxide (sugarcane transportation)', 'OUTPUT', 1078.8::numeric, 'kg'),
    ('Nitrous oxide (sugarcane transportation)', 'OUTPUT', 0.058::numeric, 'kg'),
    ('Methane (sugarcane transportation)', 'OUTPUT', 0.058::numeric, 'kg')
) AS v(flow_name, exchange_type, amount, unit_symbol)
  ON TRUE
JOIN flow f ON f.flow_name = v.flow_name
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE p.process_name = 'Sugarcane transportation (Nawapanan et al. 2022)'
  AND ps.step_order = 1
  AND pr.product_name = 'Sugarcane'
  AND b.production_quantity = 58000
  AND NOT EXISTS (
      SELECT 1 FROM lci_exchange e
      WHERE e.batch_process_id = bp.batch_process_id
        AND e.flow_id = f.flow_id
        AND e.source_id = ds.source_id
  );

-- 5. Add sugar product and its separate 1 kg reference batch.
INSERT INTO product (product_name, category_id, unit_id)
SELECT 'Sugar', c.category_id, u.unit_id
FROM product_category c
JOIN unit u ON u.unit_symbol = 'kg'
WHERE c.category_name = 'Sugarcane and sugar products'
  AND NOT EXISTS (
      SELECT 1 FROM product p WHERE p.product_name = 'Sugar'
  );

INSERT INTO production_batch (
    product_id, production_quantity, unit_id, location_id,
    production_year, area_ha
)
SELECT
    p.product_id,
    1,
    u.unit_id,
    l.location_id,
    NULL,
    NULL
FROM product p
JOIN unit u ON u.unit_symbol = 'kg'
JOIN location l
  ON l.province = 'Thailand (15-factory contract-farmer aggregate)'
WHERE p.product_name = 'Sugar'
  AND NOT EXISTS (
      SELECT 1
      FROM production_batch b
      WHERE b.product_id = p.product_id
        AND b.production_quantity = 1
        AND b.location_id = l.location_id
  );

-- 6. Create sugar production process and reference step.
INSERT INTO process (process_name, description)
SELECT
    'Sugar production (Nawapanan et al. 2022)',
    'Sugar factory inventory from Table 2, reported per 1 kg of sugar. Study data period 2016-2019. The article overall functional unit is also described as 1 tonne of sugar; this process retains the Table 2 unit-process basis.'
WHERE NOT EXISTS (
    SELECT 1 FROM process
    WHERE process_name = 'Sugar production (Nawapanan et al. 2022)'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT
    p.process_id,
    'Sugar production (per 1 kg sugar)',
    1,
    'Table 2 unit process 3. CO2 0.14 t converted to 140 kg; TDS 0.08 t converted to 80 kg; COD 0.01 t converted to 10 kg. All other values retained in kg, m3 or kWh as reported.'
FROM process p
WHERE p.process_name = 'Sugar production (Nawapanan et al. 2022)'
  AND NOT EXISTS (
      SELECT 1 FROM process_step ps
      WHERE ps.process_id = p.process_id AND ps.step_order = 1
  );

INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT
    b.batch_id,
    ps.step_id,
    1,
    b.location_id
FROM production_batch b
JOIN product pr ON pr.product_id = b.product_id
JOIN process p
  ON p.process_name = 'Sugar production (Nawapanan et al. 2022)'
JOIN process_step ps
  ON ps.process_id = p.process_id AND ps.step_order = 1
WHERE pr.product_name = 'Sugar'
  AND b.production_quantity = 1
  AND NOT EXISTS (
      SELECT 1 FROM batch_process bp
      WHERE bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
  );

-- 7. Add sugar production inputs and outputs per 1 kg sugar.
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
FROM process p
JOIN process_step ps ON ps.process_id = p.process_id
JOIN batch_process bp ON bp.step_id = ps.step_id
JOIN production_batch b ON b.batch_id = bp.batch_id
JOIN product pr ON pr.product_id = b.product_id
JOIN data_source ds
  ON ds.document_name ILIKE '%Green GDP Indicator with Application to Life Cycle of Sugar Industry in Thailand%'
JOIN (VALUES
    ('Diesel (sugar production)', 'INPUT', 0.203::numeric, 'kg'),
    ('LPG (sugar production)', 'INPUT', 0.0003::numeric, 'kg'),
    ('Fuel oil (sugar production)', 'INPUT', 0.053::numeric, 'kg'),
    ('Chemicals (sugar production)', 'INPUT', 0.00046::numeric, 'kg'),
    ('Water use (sugar production)', 'INPUT', 0.88::numeric, 'm3'),
    ('Grid electricity', 'INPUT', 135::numeric, 'kWh'),
    ('Total suspended particulates (sugar production)', 'OUTPUT', 0.76::numeric, 'kg'),
    ('Hydrogen chloride (sugar production)', 'OUTPUT', 0.011::numeric, 'kg'),
    ('Carbon monoxide (sugar production)', 'OUTPUT', 2.00::numeric, 'kg'),
    ('Sulfur dioxide (sugar production)', 'OUTPUT', 0.04::numeric, 'kg'),
    ('Nitrogen oxides (sugar production)', 'OUTPUT', 0.85::numeric, 'kg'),
    ('NMVOC (sugar production)', 'OUTPUT', 0.035::numeric, 'kg'),
    ('Carbon dioxide (sugar production)', 'OUTPUT', 140::numeric, 'kg'),
    ('Nitrous oxide (sugar production)', 'OUTPUT', 0.0049::numeric, 'kg'),
    ('Methane (sugar production)', 'OUTPUT', 0.000037::numeric, 'kg'),
    ('Total dissolved solids (sugar production)', 'OUTPUT', 80::numeric, 'kg'),
    ('Suspended solids (sugar production)', 'OUTPUT', 0.64::numeric, 'kg'),
    ('Chemical oxygen demand (sugar production)', 'OUTPUT', 10::numeric, 'kg'),
    ('Biochemical oxygen demand (sugar production)', 'OUTPUT', 0.13::numeric, 'kg')
) AS v(flow_name, exchange_type, amount, unit_symbol)
  ON TRUE
JOIN flow f ON f.flow_name = v.flow_name
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE p.process_name = 'Sugar production (Nawapanan et al. 2022)'
  AND ps.step_order = 1
  AND pr.product_name = 'Sugar'
  AND b.production_quantity = 1
  AND NOT EXISTS (
      SELECT 1 FROM lci_exchange e
      WHERE e.batch_process_id = bp.batch_process_id
        AND e.flow_id = f.flow_id
        AND e.source_id = ds.source_id
  );


-- 8. Include cultivation exchanges that were added after the initial seed.
-- Manure amount is reported in the article prose (9.38 t/ha).
-- Tops and leaves amount is reported in Table 2 (0.20 kg/ha).
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
FROM production_batch b
JOIN product pr ON pr.product_id = b.product_id
JOIN process p
  ON p.process_name = 'Sugarcane cultivation (Nawapanan et al. 2022)'
JOIN process_step ps ON ps.process_id = p.process_id
JOIN batch_process bp
  ON bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
JOIN data_source ds
  ON ds.document_name ILIKE '%Green GDP Indicator with Application to Life Cycle of Sugar Industry in Thailand%'
JOIN (VALUES
    ('Manure (green and cattle)', 'INPUT', 9380::numeric, 'kg'),
    ('Sugarcane tops and leaves', 'OUTPUT', 0.20::numeric, 'kg')
) AS v(flow_name, exchange_type, amount, unit_symbol) ON TRUE
JOIN flow f ON f.flow_name = v.flow_name
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE pr.product_name = 'Sugarcane'
  AND b.production_quantity = 58000
  AND NOT EXISTS (
      SELECT 1 FROM lci_exchange e
      WHERE e.batch_process_id = bp.batch_process_id
        AND e.flow_id = f.flow_id
        AND e.source_id = ds.source_id
  );

COMMIT;

