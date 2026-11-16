-- Thai rice milling national reference
-- Source: UNIDO (1980), Table 14B
-- Original data source stated in report: Bangkok Metropolitan Bank
-- Functional reference: 1,000 kg paddy rice
-- Table values sum to 99.994% because of rounding.
-- This dataset is NOT specific to Hom Mali or any province.

BEGIN;

-- Category and products
INSERT INTO product_category (category_name, description)
VALUES (
    'Rice milling reference',
    'Generic national-level Thai rice milling reference products; not variety-specific'
);

INSERT INTO product
(product_name, category_id, description, unit_id)
SELECT v.product_name, c.category_id, v.description, u.unit_id
FROM (VALUES
    (
        'Thai paddy rice (national milling reference)',
        'Generic Thai paddy rice used as the input to the national milling-yield reference; not specific to Hom Mali.',
        'kg'
    ),
    (
        'Thai white rice 5% (national milling reference)',
        '5% white rice output from the national average milling-yield table in UNIDO (1980), Table 14B.',
        'kg'
    )
) AS v(product_name, description, unit_symbol)
JOIN product_category c
  ON c.category_name = 'Rice milling reference'
JOIN unit u
  ON u.unit_symbol = v.unit_symbol;

-- National reference location
INSERT INTO location (province, district, country)
VALUES (
    'Thailand (National Milling Reference)',
    NULL,
    'Thailand'
);

-- Source
INSERT INTO data_source
(organization_name, document_name, publication_year, reference_url, access_date)
VALUES (
    'Bangkok Metropolitan Bank (as cited in UNIDO)',
    'Report on the Feasibility Study of Establishing a Rice Mill in the Kingdom of Thailand (10014.en), Table 14B',
    1980,
    'https://downloads.unido.org/ot/47/89/4789442/10001-15000_10014.pdf',
    CURRENT_DATE
);

-- Separate generic national milling process
INSERT INTO process (process_name, description)
VALUES (
    'Thai rice milling (national average reference, UNIDO 1980)',
    'Aggregated national average milling yields from UNIDO (1980), Table 14B. Not specific to Hom Mali, KDML 105, Surin, or Northeast Thailand. No energy or environmental inventory is reported in this dataset.'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT process_id,
       'Aggregated milling yield (Table 14B)',
       1,
       'Aggregated input-output reference. Individual milling-stage allocations are not reported.'
FROM process
WHERE process_name = 'Thai rice milling (national average reference, UNIDO 1980)';

-- Product flows for the two new products
INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT p.product_name, 'INPUT', p.product_id, p.unit_id
FROM product p
WHERE p.product_name = 'Thai paddy rice (national milling reference)';

INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT p.product_name, 'OUTPUT', p.product_id, p.unit_id
FROM product p
WHERE p.product_name = 'Thai white rice 5% (national milling reference)';

-- One reference batch: 1,000 kg paddy
INSERT INTO production_batch
(product_id, production_quantity, unit_id, location_id, production_year, area_ha)
SELECT p.product_id, 1000, u.unit_id, l.location_id, 1980, NULL
FROM product p
JOIN unit u ON u.unit_symbol = 'kg'
JOIN location l
  ON l.province = 'Thailand (National Milling Reference)'
WHERE p.product_name = 'Thai paddy rice (national milling reference)';

-- Link batch to the aggregated milling step
INSERT INTO batch_process
(batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, 1, l.location_id
FROM production_batch b
JOIN product p ON p.product_id = b.product_id
JOIN location l ON l.location_id = b.location_id
JOIN process pr
  ON pr.process_name = 'Thai rice milling (national average reference, UNIDO 1980)'
JOIN process_step ps
  ON ps.process_id = pr.process_id
 AND ps.step_order = 1
WHERE p.product_name = 'Thai paddy rice (national milling reference)'
  AND l.province = 'Thailand (National Milling Reference)'
  AND b.production_year = 1980;

-- Input and outputs, based on Table 14B percentages
INSERT INTO lci_exchange
(batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id,
       f.flow_id,
       v.exchange_type,
       v.amount,
       u.unit_id,
       ds.source_id,
       1980
FROM (VALUES
    ('Thai paddy rice (national milling reference)', 'INPUT', 1000.00::numeric),
    ('Thai white rice 5% (national milling reference)', 'OUTPUT', 401.39::numeric),
    ('Broken rice', 'OUTPUT', 266.08::numeric),
    ('Rice bran', 'OUTPUT', 97.31::numeric),
    ('Rice husk', 'OUTPUT', 235.16::numeric)
) AS v(flow_name, exchange_type, amount)
JOIN flow f ON f.flow_name = v.flow_name
JOIN unit u ON u.unit_symbol = 'kg'
JOIN data_source ds
  ON ds.document_name =
     'Report on the Feasibility Study of Establishing a Rice Mill in the Kingdom of Thailand (10014.en), Table 14B'
JOIN process pr
  ON pr.process_name = 'Thai rice milling (national average reference, UNIDO 1980)'
JOIN process_step ps
  ON ps.process_id = pr.process_id
 AND ps.step_order = 1
JOIN batch_process bp
  ON bp.step_id = ps.step_id
JOIN production_batch b
  ON b.batch_id = bp.batch_id
JOIN product p
  ON p.product_id = b.product_id
WHERE p.product_name = 'Thai paddy rice (national milling reference)'
  AND v.flow_name IN (
      'Thai paddy rice (national milling reference)',
      'Thai white rice 5% (national milling reference)',
      'Broken rice',
      'Rice bran',
      'Rice husk'
  );

COMMIT;
