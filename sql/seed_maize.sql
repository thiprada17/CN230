SET search_path TO core, catalog, process, production, lci, impact, public;
-- Maize cultivation inventory
-- Supasri et al. (2020), corrected by Author Correction (2021)
-- Field survey year: 2016
-- Reference inventory basis: 1 ha; LCIA results are reported per 1 kg maize grain
-- Inventory quantities below are reported per hectare.
-- Reference batches use 1 ha; no values are estimated for missing entries.

INSERT INTO product_category (category_name, description)
VALUES (
  'Maize and maize residues',
  'Maize grain and agricultural co-products from maize cultivation'
);

INSERT INTO location (province, district, country)
VALUES
('Chiang Mai', 'Mae Chaem', 'Thailand'),
('Chiang Mai', 'Chiang Dao', 'Thailand');

INSERT INTO data_source
(organization_name, document_name, publication_year, reference_url, access_date)
VALUES
(
  'Supasri et al.',
  'Life cycle assessment of maize cultivation and biomass utilization in northern Thailand',
  2020,
  'https://doi.org/10.1038/s41598-020-60532-2',
  CURRENT_DATE
),
(
  'Supasri et al.',
  'Author Correction: Life cycle assessment of maize cultivation and biomass utilization in northern Thailand',
  2021,
  'https://doi.org/10.1038/s41598-021-03592-2',
  CURRENT_DATE
);

INSERT INTO product (product_name, category_id, description, unit_id)
SELECT v.name, c.category_id, v.description, u.unit_id
FROM (VALUES
  ('Maize grain',
   'Main crop product; yield reported per hectare',
   'kg'),
  ('Maize residue (leaves and stalks)',
   'Agricultural co-product reported per hectare',
   'kg'),
  ('Maize cob',
   'Agricultural co-product reported per hectare',
   'kg')
) AS v(name, description, symbol)
JOIN product_category c
  ON c.category_name = 'Maize and maize residues'
JOIN unit u ON u.unit_symbol = v.symbol;

INSERT INTO process (process_name, description)
VALUES (
  'Maize cultivation (Northern Thailand)',
  'Maize cultivation case studies in Mae Chaem and Chiang Dao, Chiang Mai; field survey data from 2016'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT p.process_id, v.name, v.step_order, v.description
FROM process p
CROSS JOIN (VALUES
  ('Land preparation', 1, 'Land preparation before planting'),
  ('Planting', 2, 'Seed planting and reported planting inputs'),
  ('Weeding', 3, 'Weed control inputs'),
  ('Farming', 4, 'Fertilizer and crop management inputs'),
  ('Harvesting and milling', 5, 'Harvesting and milling operations'),
  ('Post harvesting (open burning)', 6, 'Post-harvest stage; diesel input reported in the study')
) AS v(name, step_order, description)
WHERE p.process_name = 'Maize cultivation (Northern Thailand)';

-- General input flows. Paraquat is separated by unit because
-- the study reports it in both litres and kilograms.
INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT v.name, 'INPUT', u.unit_id
FROM (VALUES
  ('Maize seed', 'kg'),
  ('Organic fertilizer', 'kg'),
  ('NPK fertilizer (15-15-15)', 'kg'),
  ('Atrazine', 'kg'),
  ('Alachlor', 'kg'),
  ('Urea (46-0-0)', 'kg'),
  ('Paraquat dichloride (L)', 'L'),
  ('Paraquat dichloride (kg)', 'kg'),
  ('Fertilizer bag', 'kg')
) AS v(name, symbol)
JOIN unit u ON u.unit_symbol = v.symbol;

-- Product output flows.
INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT p.product_name, 'OUTPUT', p.product_id, p.unit_id
FROM product p
WHERE p.product_name IN (
  'Maize grain',
  'Maize residue (leaves and stalks)',
  'Maize cob'
);

-- Reference batches: one hectare per study location.
INSERT INTO production_batch
(product_id, production_quantity, unit_id, location_id, production_year, area_ha)
SELECT p.product_id, v.yield_kg, u.unit_id, l.location_id, 2016, 1
FROM (VALUES
  ('Mae Chaem', 4400::numeric),
  ('Chiang Dao', 3419::numeric)
) AS v(district_name, yield_kg)
JOIN location l
  ON l.district = v.district_name
 AND l.province = 'Chiang Mai'
JOIN product p ON p.product_name = 'Maize grain'
JOIN unit u ON u.unit_symbol = 'kg';

-- Six process stages per location.
INSERT INTO batch_process
(batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, ps.step_order, b.location_id
FROM production_batch b
JOIN product p ON p.product_id = b.product_id
JOIN process_step ps ON TRUE
JOIN process pr ON pr.process_id = ps.process_id
WHERE p.product_name = 'Maize grain'
  AND pr.process_name = 'Maize cultivation (Northern Thailand)';

-- Table 1: inputs per hectare, by location and process stage.
INSERT INTO lci_exchange
(batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id, f.flow_id, 'INPUT', v.amount,
       u.unit_id, ds.source_id, 2016
FROM (VALUES
  -- Mae Chaem
  ('Mae Chaem', 2, 'Maize seed', 18.75::numeric, 'kg'),
  ('Mae Chaem', 2, 'Organic fertilizer', 1250::numeric, 'kg'),
  ('Mae Chaem', 2, 'NPK fertilizer (15-15-15)', 312.50::numeric, 'kg'),
  ('Mae Chaem', 3, 'Atrazine', 2.19::numeric, 'kg'),
  ('Mae Chaem', 3, 'Alachlor', 3.13::numeric, 'kg'),
  ('Mae Chaem', 4, 'NPK fertilizer (15-15-15)', 93.75::numeric, 'kg'),
  ('Mae Chaem', 4, 'Urea (46-0-0)', 312.50::numeric, 'kg'),
  ('Mae Chaem', 5, 'Diesel', 6.25::numeric, 'L'),
  ('Mae Chaem', 6, 'Diesel', 3.13::numeric, 'L'),

  -- Chiang Dao
  ('Chiang Dao', 1, 'Diesel', 18.75::numeric, 'L'),
  ('Chiang Dao', 2, 'Maize seed', 18.75::numeric, 'kg'),
  ('Chiang Dao', 2, 'Diesel', 18.75::numeric, 'L'),
  ('Chiang Dao', 3, 'Paraquat dichloride (L)', 25::numeric, 'L'),
  ('Chiang Dao', 4, 'Urea (46-0-0)', 312.50::numeric, 'kg'),
  ('Chiang Dao', 4, 'Paraquat dichloride (kg)', 12.50::numeric, 'kg'),
  ('Chiang Dao', 5, 'Diesel', 62.50::numeric, 'L'),
  ('Chiang Dao', 5, 'Fertilizer bag', 62.50::numeric, 'kg'),
  ('Chiang Dao', 6, 'Diesel', 6.25::numeric, 'L')
) AS v(district_name, step_order, flow_name, amount, unit_symbol)
JOIN location l
  ON l.district = v.district_name
 AND l.province = 'Chiang Mai'
JOIN production_batch b ON b.location_id = l.location_id
JOIN batch_process bp ON bp.batch_id = b.batch_id
JOIN process_step ps
  ON ps.step_id = bp.step_id
 AND ps.step_order = v.step_order
JOIN flow f
  ON f.flow_name = v.flow_name
 AND f.flow_type = 'INPUT'
JOIN unit u ON u.unit_symbol = v.unit_symbol
JOIN data_source ds
  ON ds.document_name =
     'Author Correction: Life cycle assessment of maize cultivation and biomass utilization in northern Thailand'
JOIN product p ON p.product_id = b.product_id
WHERE p.product_name = 'Maize grain';

-- Table 2: main product and co-products, per hectare.
INSERT INTO lci_exchange
(batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id, f.flow_id, 'OUTPUT', v.amount,
       u.unit_id, ds.source_id, 2016
FROM (VALUES
  ('Mae Chaem', 'Maize grain', 4400::numeric),
  ('Mae Chaem', 'Maize residue (leaves and stalks)', 8119::numeric),
  ('Mae Chaem', 'Maize cob', 1059::numeric),
  ('Chiang Dao', 'Maize grain', 3419::numeric),
  ('Chiang Dao', 'Maize residue (leaves and stalks)', 6288::numeric),
  ('Chiang Dao', 'Maize cob', 820::numeric)
) AS v(district_name, flow_name, amount)
JOIN location l
  ON l.district = v.district_name
 AND l.province = 'Chiang Mai'
JOIN production_batch b ON b.location_id = l.location_id
JOIN batch_process bp ON bp.batch_id = b.batch_id
JOIN process_step ps ON ps.step_id = bp.step_id AND ps.step_order = 5
JOIN flow f ON f.flow_name = v.flow_name AND f.flow_type = 'OUTPUT'
JOIN unit u ON u.unit_symbol = 'kg'
JOIN data_source ds
  ON ds.document_name =
     'Author Correction: Life cycle assessment of maize cultivation and biomass utilization in northern Thailand'
JOIN product p ON p.product_id = b.product_id
WHERE p.product_name = 'Maize grain';


-- Table 4: whole-system LCI per 1 kg maize grain.
-- IDEA v2.0 and ecoinvent v3.0 are stored as separate inventories.
-- Reference batches represent 1 kg maize grain, not actual farm lots.

BEGIN;

-- Units required by Table 4.
INSERT INTO unit (unit_name, unit_symbol, unit_type)
SELECT v.unit_name, v.unit_symbol, v.unit_type
FROM (VALUES
  ('Square metre', 'm2', 'area'),
  ('Square metre year', 'm2y', 'area-time')
) AS v(unit_name, unit_symbol, unit_type)
WHERE NOT EXISTS (
  SELECT 1 FROM unit u WHERE u.unit_symbol = v.unit_symbol
);

-- Separate source records for the two LCI databases.
INSERT INTO data_source
(organization_name, document_name, publication_year, reference_url, access_date)
SELECT 'Supasri et al.', v.document_name, 2020,
       'https://doi.org/10.1038/s41598-020-60532-2', CURRENT_DATE
FROM (VALUES
  ('Supasri et al. (2020) - Table 4 LCI using IDEA v2.0'),
  ('Supasri et al. (2020) - Table 4 LCI using ecoinvent v3.0')
) AS v(document_name)
WHERE NOT EXISTS (
  SELECT 1 FROM data_source ds
  WHERE ds.document_name = v.document_name
);

-- Separate whole-system process steps for each LCI database.
INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT p.process_id, v.step_name, v.step_order, v.description
FROM process p
CROSS JOIN (VALUES
    (
        'Whole-system LCI - IDEA v2.0 (functional unit: 1 kg maize grain)',
        7,
        'Aggregated whole-system inventory from Table 4 using IDEA v2.0, reported per 1 kg maize grain.'
    ),
    (
        'Whole-system LCI - ecoinvent v3.0 (functional unit: 1 kg maize grain)',
        8,
        'Aggregated whole-system inventory from Table 4 using ecoinvent v3.0, reported per 1 kg maize grain.'
    )
) AS v(step_name, step_order, description)
WHERE p.process_name = 'Maize cultivation (Northern Thailand)'
  AND NOT EXISTS (
      SELECT 1
      FROM process_step ps
      WHERE ps.process_id = p.process_id
        AND ps.step_order = v.step_order
  );

-- Reference batches: 1 kg maize grain for each district.
INSERT INTO production_batch
(product_id, production_quantity, unit_id, location_id, production_year, area_ha)
SELECT p.product_id, 1, u.unit_id, l.location_id, 2016, NULL
FROM product p
JOIN unit u ON u.unit_symbol = 'kg'
JOIN location l
  ON l.district IN ('Mae Chaem', 'Chiang Dao')
 AND l.province = 'Chiang Mai'
WHERE p.product_name = 'Maize grain'
  AND NOT EXISTS (
    SELECT 1
    FROM production_batch b
    WHERE b.product_id = p.product_id
      AND b.location_id = l.location_id
      AND b.production_quantity = 1
      AND b.unit_id = u.unit_id
      AND b.production_year = 2016
      AND b.area_ha IS NULL
  );

-- Link each reference batch to both database-specific process steps.
INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, ps.step_order, b.location_id
FROM production_batch b
JOIN product p ON p.product_id = b.product_id
JOIN location l ON l.location_id = b.location_id
JOIN process pr
  ON pr.process_name = 'Maize cultivation (Northern Thailand)'
JOIN process_step ps
  ON ps.process_id = pr.process_id
 AND ps.step_order IN (7, 8)
WHERE p.product_name = 'Maize grain'
  AND b.production_quantity = 1
  AND b.area_ha IS NULL
  AND b.production_year = 2016
  AND l.district IN ('Mae Chaem', 'Chiang Dao')
  AND NOT EXISTS (
      SELECT 1
      FROM batch_process bp
      WHERE bp.batch_id = b.batch_id
        AND bp.step_id = ps.step_id
  );

-- Inventory flows, separated by database.
INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT v.flow_name, v.flow_type, u.unit_id
FROM (VALUES
  ('CO2 (IDEA v2.0)', 'OUTPUT', 'kg'),
  ('SO2 (IDEA v2.0)', 'OUTPUT', 'kg'),
  ('NOx (IDEA v2.0)', 'OUTPUT', 'kg'),
  ('PM2.5 (IDEA v2.0)', 'OUTPUT', 'kg'),
  ('Oil (IDEA v2.0)', 'INPUT', 'kg'),
  ('Coal (IDEA v2.0)', 'INPUT', 'kg'),
  ('Natural gas (IDEA v2.0)', 'INPUT', 'kg'),
  ('Water (IDEA v2.0)', 'INPUT', 'm3'),
  ('Land transformation (IDEA v2.0)', 'INPUT', 'm2'),
  ('Land occupation (IDEA v2.0)', 'INPUT', 'm2y'),
  ('CO2 (ecoinvent v3.0)', 'OUTPUT', 'kg'),
  ('SO2 (ecoinvent v3.0)', 'OUTPUT', 'kg'),
  ('NOx (ecoinvent v3.0)', 'OUTPUT', 'kg'),
  ('PM2.5 (ecoinvent v3.0)', 'OUTPUT', 'kg'),
  ('Oil (ecoinvent v3.0)', 'INPUT', 'kg'),
  ('Coal (ecoinvent v3.0)', 'INPUT', 'kg'),
  ('Natural gas (ecoinvent v3.0)', 'INPUT', 'kg'),
  ('Water (ecoinvent v3.0)', 'INPUT', 'm3'),
  ('Land transformation (ecoinvent v3.0)', 'INPUT', 'm2'),
  ('Land occupation (ecoinvent v3.0)', 'INPUT', 'm2y')
) AS v(flow_name, flow_type, unit_symbol)
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE NOT EXISTS (
  SELECT 1 FROM flow f
  WHERE f.flow_name = v.flow_name AND f.flow_type = v.flow_type
);

-- Table 4 values: 10 inventory items x 2 districts x 2 databases.
INSERT INTO lci_exchange
(batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id,
       f.flow_id,
       v.exchange_type,
       v.amount,
       u.unit_id,
       ds.source_id,
       2016
FROM (VALUES
  ('Mae Chaem', 'IDEA v2.0', 'CO2', 'OUTPUT', 0.227::numeric, 'kg'),
  ('Mae Chaem', 'IDEA v2.0', 'SO2', 'OUTPUT', 0.000277, 'kg'),
  ('Mae Chaem', 'IDEA v2.0', 'NOx', 'OUTPUT', 0.00371, 'kg'),
  ('Mae Chaem', 'IDEA v2.0', 'PM2.5', 'OUTPUT', 0.0115, 'kg'),
  ('Mae Chaem', 'IDEA v2.0', 'Oil', 'INPUT', 0.0286, 'kg'),
  ('Mae Chaem', 'IDEA v2.0', 'Coal', 'INPUT', 0.00923, 'kg'),
  ('Mae Chaem', 'IDEA v2.0', 'Natural gas', 'INPUT', 0.0593, 'kg'),
  ('Mae Chaem', 'IDEA v2.0', 'Water', 'INPUT', 0.00225, 'm3'),
  ('Mae Chaem', 'IDEA v2.0', 'Land transformation', 'INPUT', 0.0000853, 'm2'),
  ('Mae Chaem', 'IDEA v2.0', 'Land occupation', 'INPUT', 0.00120, 'm2y'),

  ('Chiang Dao', 'IDEA v2.0', 'CO2', 'OUTPUT', 0.293, 'kg'),
  ('Chiang Dao', 'IDEA v2.0', 'SO2', 'OUTPUT', 0.000236, 'kg'),
  ('Chiang Dao', 'IDEA v2.0', 'NOx', 'OUTPUT', 0.00454, 'kg'),
  ('Chiang Dao', 'IDEA v2.0', 'PM2.5', 'OUTPUT', 0.0118, 'kg'),
  ('Chiang Dao', 'IDEA v2.0', 'Oil', 'INPUT', 0.0605, 'kg'),
  ('Chiang Dao', 'IDEA v2.0', 'Coal', 'INPUT', 0.00575, 'kg'),
  ('Chiang Dao', 'IDEA v2.0', 'Natural gas', 'INPUT', 0.0649, 'kg'),
  ('Chiang Dao', 'IDEA v2.0', 'Water', 'INPUT', 0.00125, 'm3'),
  ('Chiang Dao', 'IDEA v2.0', 'Land transformation', 'INPUT', 0.000110, 'm2'),
  ('Chiang Dao', 'IDEA v2.0', 'Land occupation', 'INPUT', 0.000149, 'm2y'),

  ('Mae Chaem', 'ecoinvent v3.0', 'CO2', 'OUTPUT', 0.338, 'kg'),
  ('Mae Chaem', 'ecoinvent v3.0', 'SO2', 'OUTPUT', 0.000672, 'kg'),
  ('Mae Chaem', 'ecoinvent v3.0', 'NOx', 'OUTPUT', 0.00383, 'kg'),
  ('Mae Chaem', 'ecoinvent v3.0', 'PM2.5', 'OUTPUT', 0.0115, 'kg'),
  ('Mae Chaem', 'ecoinvent v3.0', 'Oil', 'INPUT', 0.0339, 'kg'),
  ('Mae Chaem', 'ecoinvent v3.0', 'Coal', 'INPUT', 0.0154, 'kg'),
  ('Mae Chaem', 'ecoinvent v3.0', 'Natural gas', 'INPUT', 0.0486, 'kg'),
  ('Mae Chaem', 'ecoinvent v3.0', 'Water', 'INPUT', 5.96e-11, 'm3'),
  ('Mae Chaem', 'ecoinvent v3.0', 'Land transformation', 'INPUT', 0.0124, 'm2'),
  ('Mae Chaem', 'ecoinvent v3.0', 'Land occupation', 'INPUT', 0.00687, 'm2y'),

  ('Chiang Dao', 'ecoinvent v3.0', 'CO2', 'OUTPUT', 0.547, 'kg'),
  ('Chiang Dao', 'ecoinvent v3.0', 'SO2', 'OUTPUT', 0.00132, 'kg'),
  ('Chiang Dao', 'ecoinvent v3.0', 'NOx', 'OUTPUT', 0.00478, 'kg'),
  ('Chiang Dao', 'ecoinvent v3.0', 'PM2.5', 'OUTPUT', 0.0119, 'kg'),
  ('Chiang Dao', 'ecoinvent v3.0', 'Oil', 'INPUT', 0.0681, 'kg'),
  ('Chiang Dao', 'ecoinvent v3.0', 'Coal', 'INPUT', 0.0188, 'kg'),
  ('Chiang Dao', 'ecoinvent v3.0', 'Natural gas', 'INPUT', 0.0629, 'kg'),
  ('Chiang Dao', 'ecoinvent v3.0', 'Water', 'INPUT', 7.39e-11, 'm3'),
  ('Chiang Dao', 'ecoinvent v3.0', 'Land transformation', 'INPUT', 0.0170, 'm2'),
  ('Chiang Dao', 'ecoinvent v3.0', 'Land occupation', 'INPUT', 0.0254, 'm2y')
) AS v(district_name, database_name, flow_base, exchange_type, amount, unit_symbol)
JOIN location l
  ON l.district = v.district_name AND l.province = 'Chiang Mai'
JOIN production_batch b
  ON b.location_id = l.location_id
 AND b.production_quantity = 1
 AND b.area_ha IS NULL
 AND b.production_year = 2016
JOIN product p
  ON p.product_id = b.product_id AND p.product_name = 'Maize grain'
JOIN batch_process bp ON bp.batch_id = b.batch_id
JOIN process_step ps
  ON ps.step_id = bp.step_id
 AND ps.step_order = CASE
       WHEN v.database_name = 'IDEA v2.0' THEN 7
       WHEN v.database_name = 'ecoinvent v3.0' THEN 8
     END
JOIN flow f
  ON f.flow_name = v.flow_base || ' (' || v.database_name || ')'
 AND f.flow_type = v.exchange_type
JOIN unit u ON u.unit_symbol = v.unit_symbol
JOIN data_source ds
  ON ds.document_name =
     'Supasri et al. (2020) - Table 4 LCI using ' || v.database_name
WHERE NOT EXISTS (
  SELECT 1 FROM lci_exchange existing
  WHERE existing.batch_process_id = bp.batch_process_id
    AND existing.flow_id = f.flow_id
    AND existing.source_id = ds.source_id
);


-- Study-level GWP: Supasri et al. (2020), per 1 kg maize grain.
-- The reported 351.2 g CO2-eq is converted to 0.3512 kg CO2-eq.
INSERT INTO study_impact
(source_id, product_id, impact_type, impact_amount, unit_id,
 functional_unit_quantity, functional_unit_unit_id, location_id,
 impact_method, data_year, system_boundary, notes)
SELECT
    ds.source_id,
    p.product_id,
    'Global warming',
    0.3512,
    iu.unit_id,
    1,
    fu.unit_id,
    NULL,
    NULL,
    NULL,
    'Maize grain cultivation; study-level result per 1 kg maize grain.',
    'Supasri et al. (2020). Source reports 351.2 g CO2-eq per 1 kg maize grain; converted to 0.3512 kg CO2-eq. No single district is assigned to this study-level result.'
FROM data_source ds
JOIN product p ON p.product_name = 'Maize grain'
JOIN unit iu ON iu.unit_symbol = 'kg CO2-eq'
JOIN unit fu ON fu.unit_symbol = 'kg'
WHERE ds.document_name =
    'Life cycle assessment of maize cultivation and biomass utilization in northern Thailand'
  AND NOT EXISTS (
      SELECT 1
      FROM study_impact existing
      WHERE existing.source_id = ds.source_id
        AND existing.product_id = p.product_id
        AND existing.impact_type = 'Global warming'
        AND existing.functional_unit_quantity = 1
        AND existing.functional_unit_unit_id = fu.unit_id
        AND existing.location_id IS NULL
  );

COMMIT;

