-- Pineapple processing by-products in Thailand
-- Source: Hemung et al. (2022), review article.
-- National processing estimate for 2020.
-- The source reports peels 35.5%, cores 14.7%, stems 4.6%, crowns 4.3%.
-- Stems and crowns are grouped as other processing residues (8.9%).
-- No separate aggregate by-product output is added, avoiding double counting.

BEGIN;

INSERT INTO data_source (
    organization_name, document_name, publication_year,
    reference_url, access_date
)
SELECT
    'Hemung et al.',
    'A study of the potential of by-products from pineapple processing in Thailand',
    2022,
    'https://doi.org/10.53730/ijhs.v6nS4.12131',
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM data_source
    WHERE document_name =
    'A study of the potential of by-products from pineapple processing in Thailand'
);

INSERT INTO location (province, country)
SELECT 'Thailand (national pineapple-processing estimate)', 'Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM location
    WHERE province = 'Thailand (national pineapple-processing estimate)'
      AND country = 'Thailand'
);

-- Feedstock and by-product products
INSERT INTO product (product_name, category_id, description, unit_id)
SELECT v.product_name, pc.category_id, v.description, u.unit_id
FROM (VALUES
    ('Pineapple feedstock for processing (national estimate)',
     'National annual pineapple quantity used as the reference basis for the 2020 by-product estimate.'),
    ('Pineapple peel',
     'Pineapple peel by-product; approximately 35.5% of processing feedstock in Hemung et al. (2022).'),
    ('Pineapple core',
     'Pineapple core by-product; approximately 14.7% of processing feedstock in Hemung et al. (2022).'),
    ('Pineapple processing residues (stems and crowns)',
     'Combined pineapple stems (4.6%) and crowns (4.3%); grouped as other processing residues to avoid double counting.')
) AS v(product_name, description)
JOIN product_category pc
  ON pc.category_name = 'Pineapple and pineapple products'
JOIN unit u ON u.unit_symbol = 'kg'
WHERE NOT EXISTS (
    SELECT 1 FROM product p
    WHERE p.product_name = v.product_name
);

INSERT INTO process (process_name, description)
SELECT
    'Pineapple processing by-product generation (Hemung et al. 2022)',
    'National estimate of pineapple processing by-products in Thailand for 2020. The review reports annual production of 1,689,884 tonnes and estimates peels, cores, stems and crowns.'
WHERE NOT EXISTS (
    SELECT 1 FROM process
    WHERE process_name = 'Pineapple processing by-product generation (Hemung et al. 2022)'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT
    p.process_id,
    'Separation of pineapple processing by-products',
    1,
    'Estimated national by-product quantities for 2020. Stems and crowns are combined as other processing residues.'
FROM process p
WHERE p.process_name = 'Pineapple processing by-product generation (Hemung et al. 2022)'
  AND NOT EXISTS (
      SELECT 1 FROM process_step ps
      WHERE ps.process_id = p.process_id AND ps.step_order = 1
  );

-- National annual feedstock batch: 1,689,884 tonnes converted to kg
INSERT INTO production_batch (
    product_id, production_quantity, unit_id,
    location_id, production_year, area_ha
)
SELECT
    p.product_id,
    1689884000,
    u.unit_id,
    l.location_id,
    2020,
    NULL
FROM product p
JOIN unit u ON u.unit_symbol = 'kg'
JOIN location l
  ON l.province = 'Thailand (national pineapple-processing estimate)'
 AND l.country = 'Thailand'
WHERE p.product_name = 'Pineapple feedstock for processing (national estimate)'
  AND NOT EXISTS (
      SELECT 1 FROM production_batch b
      WHERE b.product_id = p.product_id
        AND b.production_quantity = 1689884000
        AND b.unit_id = u.unit_id
        AND b.location_id = l.location_id
        AND b.production_year = 2020
  );

INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, 1, b.location_id
FROM production_batch b
JOIN product p ON p.product_id = b.product_id
JOIN process pr
  ON pr.process_name = 'Pineapple processing by-product generation (Hemung et al. 2022)'
JOIN process_step ps ON ps.process_id = pr.process_id AND ps.step_order = 1
WHERE p.product_name = 'Pineapple feedstock for processing (national estimate)'
  AND b.production_quantity = 1689884000
  AND b.production_year = 2020
  AND NOT EXISTS (
      SELECT 1 FROM batch_process bp
      WHERE bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
  );

-- Product-linked flows
INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT v.flow_name, v.flow_type, p.product_id, u.unit_id
FROM (VALUES
    ('Pineapple feedstock input (2020 national estimate)', 'INPUT',
     'Pineapple feedstock for processing (national estimate)'),
    ('Pineapple peel output (2020 national estimate)', 'OUTPUT',
     'Pineapple peel'),
    ('Pineapple core output (2020 national estimate)', 'OUTPUT',
     'Pineapple core'),
    ('Pineapple processing residues output (stems and crowns)', 'OUTPUT',
     'Pineapple processing residues (stems and crowns)')
) AS v(flow_name, flow_type, product_name)
JOIN product p ON p.product_name = v.product_name
JOIN unit u ON u.unit_symbol = 'kg'
WHERE NOT EXISTS (
    SELECT 1 FROM flow f
    WHERE f.flow_name = v.flow_name
      AND f.flow_type = v.flow_type
      AND f.product_id = p.product_id
      AND f.unit_id = u.unit_id
);

-- Quantities derived from the review's 2020 national estimate.
-- 35.5% = 596,713.9 tonnes; 14.7% = 247,090.0 tonnes.
-- Stems + crowns = (4.6% + 4.3%) = 149,598.6 tonnes.
-- Values are taken from Table 1, which reports a total of 993,402.5 tonnes.

INSERT INTO lci_exchange (
    batch_process_id, flow_id, exchange_type, amount,
    unit_id, source_id, data_year
)
SELECT
    bp.batch_process_id,
    f.flow_id,
    v.exchange_type,
    v.amount,
    u.unit_id,
    ds.source_id,
    2020
FROM (VALUES
    ('Pineapple feedstock input (2020 national estimate)', 'INPUT',
     1689884000::numeric),
    ('Pineapple peel output (2020 national estimate)', 'OUTPUT',
     596713900::numeric),
    ('Pineapple core output (2020 national estimate)', 'OUTPUT',
     247090000::numeric),
    ('Pineapple processing residues output (stems and crowns)', 'OUTPUT',
     149598600::numeric)
) AS v(flow_name, exchange_type, amount)
JOIN product p
  ON p.product_name = 'Pineapple feedstock for processing (national estimate)'
JOIN production_batch b
  ON b.product_id = p.product_id
 AND b.production_quantity = 1689884000
 AND b.production_year = 2020
JOIN process pr
  ON pr.process_name = 'Pineapple processing by-product generation (Hemung et al. 2022)'
JOIN process_step ps ON ps.process_id = pr.process_id AND ps.step_order = 1
JOIN batch_process bp ON bp.batch_id = b.batch_id AND bp.step_id = ps.step_id
JOIN flow f ON f.flow_name = v.flow_name AND f.flow_type = v.exchange_type
JOIN unit u ON u.unit_symbol = 'kg'
JOIN data_source ds
  ON ds.document_name =
  'A study of the potential of by-products from pineapple processing in Thailand'
WHERE NOT EXISTS (
    SELECT 1 FROM lci_exchange e
    WHERE e.batch_process_id = bp.batch_process_id
      AND e.flow_id = f.flow_id
      AND e.source_id = ds.source_id
      AND e.amount = v.amount
      AND e.data_year = 2020
);

COMMIT;
