-- Pineapple cultivation and canned pineapple production
-- Source: Usubharatana & Phungrassami (2017), Tables 1, 4, 6 and 7.
-- Cultivation data period: 2010-2011.
-- Cultivation FU: 1 hectare, with three farm-size scenarios.
-- Canned pineapple FU: one can, net weight 30 oz.
-- Canned inventory is reported after 25% mass allocation.
-- Values reported only as "<" are intentionally excluded.

BEGIN;

-- 1. Category, unit, source and locations
INSERT INTO product_category (category_name, description)
VALUES (
    'Pineapple and pineapple products',
    'Pineapple cultivation, canned pineapple and processing by-products'
)
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO unit (unit_name, unit_symbol, unit_type)
SELECT 'Can, net weight 30 oz.', 'can (30 oz)', 'count'
WHERE NOT EXISTS (
    SELECT 1 FROM unit WHERE unit_symbol = 'can (30 oz)'
);

INSERT INTO data_source (
    organization_name, document_name, publication_year,
    reference_url, access_date
)
SELECT
    'Usubharatana, P. and Phungrassami, H.',
    'Evaluation of Opportunities to Reduce the Carbon Footprint of Fresh and Canned Pineapple Processing in Central Thailand',
    2017,
    'https://doi.org/10.15244/pjoes/69442',
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM data_source
    WHERE document_name =
    'Evaluation of Opportunities to Reduce the Carbon Footprint of Fresh and Canned Pineapple Processing in Central Thailand'
);

INSERT INTO location (province, country)
SELECT 'Central Thailand (25-farm pineapple study)', 'Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM location
    WHERE province = 'Central Thailand (25-farm pineapple study)'
      AND country = 'Thailand'
);

INSERT INTO location (province, country)
SELECT 'Central Thailand (canning factory case study)', 'Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM location
    WHERE province = 'Central Thailand (canning factory case study)'
      AND country = 'Thailand'
);

-- 2. Products
INSERT INTO product (product_name, category_id, description, unit_id)
SELECT v.product_name, pc.category_id, v.description, u.unit_id
FROM (VALUES
    ('Pineapple (fresh)',
     'Fresh Smooth Cayenne pineapple; cultivation inventory from three farm-size scenarios.'),
    ('Canned pineapple (30 oz.)',
     'Canned pineapple with net weight 30 oz.; functional unit used in the 2017 study.')
) AS v(product_name, description)
JOIN product_category pc
  ON pc.category_name = 'Pineapple and pineapple products'
JOIN unit u
  ON u.unit_symbol = CASE
      WHEN v.product_name = 'Pineapple (fresh)' THEN 'kg'
      ELSE 'can (30 oz)'
  END
WHERE NOT EXISTS (
    SELECT 1 FROM product p
    WHERE p.product_name = v.product_name
);

-- 3. Processes and process steps
INSERT INTO process (process_name, description)
SELECT
    'Pineapple cultivation (Usubharatana & Phungrassami 2017)',
    'Cultivation and harvesting inventory from 25 farms in Thailand. Data period 2010-2011. Three farm-size scenarios are recorded separately.'
WHERE NOT EXISTS (
    SELECT 1 FROM process
    WHERE process_name = 'Pineapple cultivation (Usubharatana & Phungrassami 2017)'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT p.process_id, v.step_name, v.step_order, v.description
FROM process p
CROSS JOIN (VALUES
    ('Soil preparation', 1,
     'Soil preparation inputs per hectare, Table 1.'),
    ('Cultivation and harvesting', 2,
     'Cultivation and harvesting inputs and harvested pineapple output per hectare, Table 1.')
) AS v(step_name, step_order, description)
WHERE p.process_name = 'Pineapple cultivation (Usubharatana & Phungrassami 2017)'
  AND NOT EXISTS (
      SELECT 1 FROM process_step ps
      WHERE ps.process_id = p.process_id
        AND ps.step_order = v.step_order
  );

INSERT INTO process (process_name, description)
SELECT
    'Canned pineapple production (Usubharatana & Phungrassami 2017)',
    'Canned pineapple processing inventory per 30 oz. can. Includes fresh pineapple, packaging, sugar, electricity and coal. Inventory reflects 25% mass allocation to canned pineapple.'
WHERE NOT EXISTS (
    SELECT 1 FROM process
    WHERE process_name = 'Canned pineapple production (Usubharatana & Phungrassami 2017)'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT
    p.process_id,
    'Canning and packaging (one 30 oz. can)',
    1,
    'Aggregated processing inventory from Table 4. Values reported below detection thresholds are excluded.'
FROM process p
WHERE p.process_name = 'Canned pineapple production (Usubharatana & Phungrassami 2017)'
  AND NOT EXISTS (
      SELECT 1 FROM process_step ps
      WHERE ps.process_id = p.process_id AND ps.step_order = 1
  );

-- 4. Production batches: three cultivation scenarios
INSERT INTO production_batch (
    product_id, production_quantity, unit_id,
    location_id, production_year, area_ha
)
SELECT
    p.product_id,
    v.yield_kg,
    u.unit_id,
    l.location_id,
    NULL,
    1
FROM (VALUES
    ('Small farm', 31250::numeric),
    ('Medium-sized farm', 36163::numeric),
    ('Large farm', 38238::numeric)
) AS v(scenario, yield_kg)
JOIN product p ON p.product_name = 'Pineapple (fresh)'
JOIN unit u ON u.unit_symbol = 'kg'
JOIN location l
  ON l.province = 'Central Thailand (25-farm pineapple study)'
 AND l.country = 'Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM production_batch b
    WHERE b.product_id = p.product_id
      AND b.production_quantity = v.yield_kg
      AND b.unit_id = u.unit_id
      AND b.location_id = l.location_id
      AND b.area_ha = 1
      AND b.production_year IS NULL
);

-- Canned pineapple batch: one 30 oz. can
INSERT INTO production_batch (
    product_id, production_quantity, unit_id,
    location_id, production_year, area_ha
)
SELECT
    p.product_id, 1, u.unit_id, l.location_id, NULL, NULL
FROM product p
JOIN unit u ON u.unit_symbol = 'can (30 oz)'
JOIN location l
  ON l.province = 'Central Thailand (canning factory case study)'
 AND l.country = 'Thailand'
WHERE p.product_name = 'Canned pineapple (30 oz.)'
  AND NOT EXISTS (
      SELECT 1 FROM production_batch b
      WHERE b.product_id = p.product_id
        AND b.production_quantity = 1
        AND b.unit_id = u.unit_id
        AND b.location_id = l.location_id
  );

-- 5. Link batches to process steps
INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, ps.step_order, b.location_id
FROM production_batch b
JOIN product pr ON pr.product_id = b.product_id
JOIN location l ON l.location_id = b.location_id
JOIN process p
  ON p.process_name = 'Pineapple cultivation (Usubharatana & Phungrassami 2017)'
JOIN process_step ps ON ps.process_id = p.process_id
WHERE pr.product_name = 'Pineapple (fresh)'
  AND b.area_ha = 1
  AND l.province = 'Central Thailand (25-farm pineapple study)'
  AND NOT EXISTS (
      SELECT 1 FROM batch_process bp
      WHERE bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
  );

INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, 1, b.location_id
FROM production_batch b
JOIN product pr ON pr.product_id = b.product_id
JOIN location l ON l.location_id = b.location_id
JOIN process p
  ON p.process_name = 'Canned pineapple production (Usubharatana & Phungrassami 2017)'
JOIN process_step ps ON ps.process_id = p.process_id AND ps.step_order = 1
WHERE pr.product_name = 'Canned pineapple (30 oz.)'
  AND l.province = 'Central Thailand (canning factory case study)'
  AND NOT EXISTS (
      SELECT 1 FROM batch_process bp
      WHERE bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
  );

-- 6. Flows
INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT v.flow_name, v.flow_type, p.product_id, u.unit_id
FROM (VALUES
    ('Fresh pineapple (cultivation output)', 'OUTPUT', 'Pineapple (fresh)', 'kg'),
    ('Fresh pineapple (canned production input)', 'INPUT', 'Pineapple (fresh)', 'kg'),
    ('Canned pineapple (30 oz.)', 'OUTPUT', 'Canned pineapple (30 oz.)', 'can (30 oz)')
) AS v(flow_name, flow_type, product_name, unit_symbol)
JOIN product p ON p.product_name = v.product_name
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE NOT EXISTS (
    SELECT 1 FROM flow f
    WHERE f.flow_name = v.flow_name
      AND f.flow_type = v.flow_type
      AND f.product_id = p.product_id
      AND f.unit_id = u.unit_id
);

INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT v.flow_name, 'INPUT', u.unit_id
FROM (VALUES
    ('Chicken manure fertilizer (pineapple cultivation)', 'kg'),
    ('Nitrogen fertilizer (pineapple cultivation)', 'kg'),
    ('Phosphorus fertilizer (pineapple cultivation)', 'kg'),
    ('Potassium fertilizer (pineapple cultivation)', 'kg'),
    ('Diesel (pineapple cultivation)', 'L'),
    ('Ethephon (pineapple cultivation)', 'kg'),
    ('Calcium carbide (pineapple cultivation)', 'kg'),
    ('Herbicide (pineapple cultivation)', 'kg'),
    ('Insecticide (pineapple cultivation)', 'kg'),
    ('Gasoline (pineapple cultivation)', 'L'),
    ('LPG (pineapple cultivation)', 'kg'),
    ('Tin can (pineapple processing)', 'kg'),
    ('Cardboard (pineapple processing)', 'kg'),
    ('Sugar (pineapple processing)', 'kg'),
    ('Electricity (pineapple processing)', 'kWh'),
    ('Coal (pineapple processing)', 'kg')
) AS v(flow_name, unit_symbol)
JOIN unit u ON u.unit_symbol = v.unit_symbol
WHERE NOT EXISTS (
    SELECT 1 FROM flow f
    WHERE f.flow_name = v.flow_name
      AND f.flow_type = 'INPUT'
      AND f.unit_id = u.unit_id
);

-- 7. Cultivation exchanges: Table 1
INSERT INTO lci_exchange (
    batch_process_id, flow_id, exchange_type, amount,
    unit_id, source_id, data_year, data_period_start, data_period_end
)
SELECT
    bp.batch_process_id,
    f.flow_id,
    'INPUT',
    v.amount,
    u.unit_id,
    ds.source_id,
    NULL,
    2010,
    2011
FROM (VALUES
    ('Small farm',31250::numeric,1,'Chicken manure fertilizer (pineapple cultivation)',18750::numeric,'kg'),
    ('Small farm',31250::numeric,1,'Diesel (pineapple cultivation)',656.25::numeric,'L'),
    ('Small farm',31250::numeric,2,'Chicken manure fertilizer (pineapple cultivation)',18750::numeric,'kg'),
    ('Small farm',31250::numeric,2,'Nitrogen fertilizer (pineapple cultivation)',19.38::numeric,'kg'),
    ('Small farm',31250::numeric,2,'Phosphorus fertilizer (pineapple cultivation)',19.38::numeric,'kg'),
    ('Small farm',31250::numeric,2,'Potassium fertilizer (pineapple cultivation)',19.38::numeric,'kg'),
    ('Small farm',31250::numeric,2,'Herbicide (pineapple cultivation)',9.38::numeric,'kg'),
    ('Small farm',31250::numeric,2,'Insecticide (pineapple cultivation)',3.13::numeric,'kg'),

    ('Medium-sized farm',36163::numeric,1,'Chicken manure fertilizer (pineapple cultivation)',5356::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,1,'Nitrogen fertilizer (pineapple cultivation)',3.38::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,1,'Phosphorus fertilizer (pineapple cultivation)',3.38::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,1,'Potassium fertilizer (pineapple cultivation)',3.38::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,1,'Diesel (pineapple cultivation)',818.13::numeric,'L'),
    ('Medium-sized farm',36163::numeric,2,'Chicken manure fertilizer (pineapple cultivation)',16519::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Nitrogen fertilizer (pineapple cultivation)',44.50::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Phosphorus fertilizer (pineapple cultivation)',10.94::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Potassium fertilizer (pineapple cultivation)',46.63::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Ethephon (pineapple cultivation)',1.13::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Calcium carbide (pineapple cultivation)',0.69::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Herbicide (pineapple cultivation)',9.38::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Insecticide (pineapple cultivation)',0.56::numeric,'kg'),
    ('Medium-sized farm',36163::numeric,2,'Diesel (pineapple cultivation)',37.94::numeric,'L'),

    ('Large farm',38238::numeric,1,'Chicken manure fertilizer (pineapple cultivation)',4994::numeric,'kg'),
    ('Large farm',38238::numeric,1,'Nitrogen fertilizer (pineapple cultivation)',5::numeric,'kg'),
    ('Large farm',38238::numeric,1,'Phosphorus fertilizer (pineapple cultivation)',5::numeric,'kg'),
    ('Large farm',38238::numeric,1,'Potassium fertilizer (pineapple cultivation)',5::numeric,'kg'),
    ('Large farm',38238::numeric,1,'Diesel (pineapple cultivation)',645.63::numeric,'L'),
    ('Large farm',38238::numeric,2,'Chicken manure fertilizer (pineapple cultivation)',8875::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Nitrogen fertilizer (pineapple cultivation)',70.31::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Phosphorus fertilizer (pineapple cultivation)',21.56::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Potassium fertilizer (pineapple cultivation)',102.94::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Ethephon (pineapple cultivation)',1.50::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Calcium carbide (pineapple cultivation)',5::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Herbicide (pineapple cultivation)',8::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Insecticide (pineapple cultivation)',0.88::numeric,'kg'),
    ('Large farm',38238::numeric,2,'Diesel (pineapple cultivation)',107.25::numeric,'L'),
    ('Large farm',38238::numeric,2,'Gasoline (pineapple cultivation)',82.81::numeric,'L'),
    ('Large farm',38238::numeric,2,'LPG (pineapple cultivation)',33.31::numeric,'kg')
) AS v(scenario, batch_quantity, step_order, flow_name, amount, unit_symbol)
JOIN product p ON p.product_name = 'Pineapple (fresh)'
JOIN production_batch b
  ON b.product_id = p.product_id
 AND b.production_quantity = v.batch_quantity
 AND b.area_ha = 1
JOIN location l ON l.location_id = b.location_id
 AND l.province = 'Central Thailand (25-farm pineapple study)'
JOIN process pr
  ON pr.process_name = 'Pineapple cultivation (Usubharatana & Phungrassami 2017)'
JOIN process_step ps
  ON ps.process_id = pr.process_id AND ps.step_order = v.step_order
JOIN batch_process bp
  ON bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
JOIN flow f ON f.flow_name = v.flow_name AND f.flow_type = 'INPUT'
JOIN unit u ON u.unit_symbol = v.unit_symbol
JOIN data_source ds
  ON ds.document_name =
  'Evaluation of Opportunities to Reduce the Carbon Footprint of Fresh and Canned Pineapple Processing in Central Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM lci_exchange e
    WHERE e.batch_process_id = bp.batch_process_id
      AND e.flow_id = f.flow_id
      AND e.source_id = ds.source_id
      AND e.amount = v.amount
      AND e.data_period_start = 2010
      AND e.data_period_end = 2011
);

-- Harvested fresh pineapple outputs
INSERT INTO lci_exchange (
    batch_process_id, flow_id, exchange_type, amount,
    unit_id, source_id, data_year, data_period_start, data_period_end
)
SELECT
    bp.batch_process_id, f.flow_id, 'OUTPUT',
    b.production_quantity, u.unit_id, ds.source_id,
    NULL, 2010, 2011
FROM production_batch b
JOIN product p ON p.product_id = b.product_id
JOIN location l ON l.location_id = b.location_id
JOIN process pr
  ON pr.process_name = 'Pineapple cultivation (Usubharatana & Phungrassami 2017)'
JOIN process_step ps ON ps.process_id = pr.process_id AND ps.step_order = 2
JOIN batch_process bp ON bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
JOIN flow f
  ON f.flow_name = 'Fresh pineapple (cultivation output)'
 AND f.flow_type = 'OUTPUT'
JOIN unit u ON u.unit_symbol = 'kg'
JOIN data_source ds
  ON ds.document_name =
  'Evaluation of Opportunities to Reduce the Carbon Footprint of Fresh and Canned Pineapple Processing in Central Thailand'
WHERE p.product_name = 'Pineapple (fresh)'
  AND b.area_ha = 1
  AND l.province = 'Central Thailand (25-farm pineapple study)'
  AND NOT EXISTS (
      SELECT 1 FROM lci_exchange e
      WHERE e.batch_process_id = bp.batch_process_id
        AND e.flow_id = f.flow_id
        AND e.source_id = ds.source_id
        AND e.exchange_type = 'OUTPUT'
  );

-- 8. Canned pineapple processing exchanges: Table 4
INSERT INTO lci_exchange (
    batch_process_id, flow_id, exchange_type, amount,
    unit_id, source_id, data_year, data_period_start, data_period_end
)
SELECT
    bp.batch_process_id, f.flow_id, v.exchange_type, v.amount,
    u.unit_id, ds.source_id, NULL, 2010, 2011
FROM (VALUES
    ('Fresh pineapple (canned production input)', 'INPUT', 0.66::numeric, 'kg'),
    ('Tin can (pineapple processing)', 'INPUT', 0.10::numeric, 'kg'),
    ('Cardboard (pineapple processing)', 'INPUT', 0.02::numeric, 'kg'),
    ('Sugar (pineapple processing)', 'INPUT', 0.80::numeric, 'kg'),
    ('Electricity (pineapple processing)', 'INPUT', 0.02::numeric, 'kWh'),
    ('Coal (pineapple processing)', 'INPUT', 0.04::numeric, 'kg'),
    ('Canned pineapple (30 oz.)', 'OUTPUT', 1::numeric, 'can (30 oz)')
) AS v(flow_name, exchange_type, amount, unit_symbol)
JOIN product p ON p.product_name = 'Canned pineapple (30 oz.)'
JOIN production_batch b ON b.product_id = p.product_id
JOIN location l ON l.location_id = b.location_id
 AND l.province = 'Central Thailand (canning factory case study)'
JOIN process pr
  ON pr.process_name = 'Canned pineapple production (Usubharatana & Phungrassami 2017)'
JOIN process_step ps ON ps.process_id = pr.process_id AND ps.step_order = 1
JOIN batch_process bp ON bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
JOIN flow f ON f.flow_name = v.flow_name AND f.flow_type = v.exchange_type
JOIN unit u ON u.unit_symbol = v.unit_symbol
JOIN data_source ds
  ON ds.document_name =
  'Evaluation of Opportunities to Reduce the Carbon Footprint of Fresh and Canned Pineapple Processing in Central Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM lci_exchange e
    WHERE e.batch_process_id = bp.batch_process_id
      AND e.flow_id = f.flow_id
      AND e.source_id = ds.source_id
      AND e.exchange_type = v.exchange_type
      AND e.amount = v.amount
);

-- 9. Study-level carbon footprint: Tables 6 and 7
INSERT INTO study_impact (
    source_id, product_id, impact_type, impact_amount,
    unit_id, functional_unit_quantity, functional_unit_unit_id,
    location_id, impact_method, data_year, system_boundary, notes
)
SELECT
    ds.source_id,
    p.product_id,
    'Global warming potential',
    v.impact_amount,
    impact_u.unit_id,
    1,
    fu.unit_id,
    l.location_id,
    'Carbon footprint; ISO 14067:2013; GWP100',
    NULL,
    v.system_boundary,
    v.notes
FROM (VALUES
    ('Pineapple (fresh)', 0.31992::numeric, 'kg',
     'Cradle-to-farm gate',
     'Small-farm scenario; Table 6 reports 319.92 g CO2-eq/kg fresh pineapple. Data collected during 2010-2011.'),
    ('Pineapple (fresh)', 0.21058::numeric, 'kg',
     'Cradle-to-farm gate',
     'Medium-sized-farm scenario; Table 6 reports 210.58 g CO2-eq/kg fresh pineapple. Data collected during 2010-2011.'),
    ('Pineapple (fresh)', 0.16518::numeric, 'kg',
     'Cradle-to-farm gate',
     'Large-farm scenario; Table 6 reports 165.18 g CO2-eq/kg fresh pineapple. Data collected during 2010-2011.'),
    ('Pineapple (fresh)', 0.172::numeric, 'kg',
     'Cradle-to-farm gate',
     'Overall average reported in the abstract: 172 g CO2-eq/kg fresh pineapple. This is the study-wide average, not an additional farm scenario.'),
    ('Canned pineapple (30 oz.)', 0.73784::numeric, 'can (30 oz)',
     'Cradle-to-factory gate',
     'Table 7 total: 737.84 g CO2-eq per 30 oz. can, converted to 0.73784 kg CO2-eq/can.')
) AS v(product_name, impact_amount, functional_unit_symbol, system_boundary, notes)
JOIN data_source ds
  ON ds.document_name =
  'Evaluation of Opportunities to Reduce the Carbon Footprint of Fresh and Canned Pineapple Processing in Central Thailand'
JOIN product p ON p.product_name = v.product_name
JOIN unit impact_u ON impact_u.unit_symbol = 'kg CO2-eq'
JOIN unit fu ON fu.unit_symbol = v.functional_unit_symbol
JOIN location l
  ON l.province = CASE
      WHEN v.product_name = 'Pineapple (fresh)'
      THEN 'Central Thailand (25-farm pineapple study)'
      ELSE 'Central Thailand (canning factory case study)'
  END
 AND l.country = 'Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM study_impact si
    WHERE si.source_id = ds.source_id
      AND si.product_id = p.product_id
      AND si.impact_type = 'Global warming potential'
      AND si.impact_amount = v.impact_amount
      AND si.functional_unit_quantity = 1
      AND si.functional_unit_unit_id = fu.unit_id
      AND si.notes = v.notes
);

COMMIT;
