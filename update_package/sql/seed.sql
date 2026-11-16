-- Agri LCI Database - Seed Data
-- Domain: Food & Agro-processing
-- Sources: Mungkung et al. (2019, 2020); Khomkaew (2022)
-- Run after sql/schema.sql on a fresh database.
-- Important: milling products/process are registered as master data only.
-- No milling batch quantities are inserted because the published abstract's
-- reported output quantities do not form a consistent mass balance.

-- Units
INSERT INTO unit (unit_name, unit_symbol, unit_type)
VALUES
('Kilogram', 'kg', 'mass'),
('Liter', 'L', 'volume'),
('Cubic metre', 'm3', 'volume'),
('Kilowatt hour', 'kWh', 'energy'),
('Kilogram carbon dioxide equivalent', 'kg CO2-eq', 'impact'),
('Kilogram sulfur dioxide equivalent', 'kg SO2-eq', 'impact'),
('Kilogram phosphate equivalent', 'kg PO4-eq', 'impact'),
('Kilogram 1,4-dichlorobenzene', 'kg 1,4-DCB', 'impact');

-- Product categories
INSERT INTO product_category (category_name, description)
VALUES
('Organic rice', 'Organic Hom Mali paddy rice'),
('Milled rice and rice by-products', 'Products and by-products generated from rice milling');

-- Locations
INSERT INTO location (province, country)
VALUES
('Surin', 'Thailand'),
('Northeast Thailand (Regional Average)', 'Thailand');

-- Data sources
INSERT INTO data_source
(organization_name, document_name, publication_year, reference_url, access_date)
VALUES
('Mungkung et al.',
 'Life Cycle Assessment of Thai organic Hom Mali rice to evaluate the climate change, water use and biodiversity impacts',
 2019,
 'https://doi.org/10.1016/j.jclepro.2018.11.197',
 CURRENT_DATE),
('Mungkung et al.',
 'Life Cycle Assessment of Thai Hom Mali Rice to Support the Policy Decision on Organic Farming Area Expansion',
 2020,
 'https://doi.org/10.3390/su12156003',
 CURRENT_DATE),
('Khomkaew, S.',
 'Effect of Paddy Moisture Content on Milling Rice Recovery of Small Milling Machine',
 2022,
 'https://ph02.tci-thaijo.org/index.php/sej/article/view/245528',
 CURRENT_DATE);

-- Products: paddy rice and milling products/by-products
INSERT INTO product (product_name, category_id, description, unit_id)
SELECT
    'Organic Hom Mali paddy rice (KDML 105)',
    c.category_id,
    'Organic Hom Mali paddy rice studied in Thailand',
    u.unit_id
FROM product_category c
CROSS JOIN unit u
WHERE c.category_name = 'Organic rice' AND u.unit_symbol = 'kg';

INSERT INTO product (product_name, category_id, description, unit_id)
SELECT v.product_name, c.category_id, v.description, u.unit_id
FROM (VALUES
 ('Milled Hom Mali rice', 'Whole milled rice product; no production quantity loaded yet'),
 ('Broken rice', 'Broken rice fraction from milling; no production quantity loaded yet'),
 ('Withered rice', 'Withered rice fraction reported in the KDML 105 milling study'),
 ('Rice bran', 'Rice bran by-product from milling'),
 ('Rice husk', 'Rice husk by-product from husking')
) AS v(product_name, description)
JOIN product_category c
  ON c.category_name = 'Milled rice and rice by-products'
JOIN unit u ON u.unit_symbol = 'kg';

-- Materials
INSERT INTO material (material_name, material_type, unit_id, description)
SELECT v.name, v.type, u.unit_id, v.description
FROM (VALUES
 ('Rice seed', 'Seed', 'kg', 'Rice seed'),
 ('Manure (green and cattle)', 'Organic fertilizer', 'kg', 'Green manure and cattle manure'),
 ('Compost', 'Organic fertilizer', 'kg', 'Compost'),
 ('Organic fertilizer (pellet)', 'Organic fertilizer', 'kg', 'Pellet fertilizer'),
 ('Organic fertilizer (liquid)', 'Organic fertilizer', 'kg', 'Liquid fertilizer'),
 ('Diesel', 'Fuel', 'L', 'Agricultural diesel')
) AS v(name, type, symbol, description)
JOIN unit u ON u.unit_symbol = v.symbol;

-- Processes and steps
INSERT INTO process (process_name, description)
VALUES
('Organic Hom Mali rice cultivation',
 'Organic rice cultivation process'),
('Hom Mali rice milling',
 'Post-harvest rice processing: cleaning, husking and whitening; no quantitative batch inventory loaded yet');

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT p.process_id, v.name, v.step_order, v.description
FROM process p
CROSS JOIN (VALUES
 ('Field preparation', 1, 'Field preparation'),
 ('Cultivation (whole crop-cycle inventory)', 2,
  'Aggregated inventory for the whole crop cycle; inputs are not allocated to individual stages'),
 ('Harvesting', 3, 'Harvesting paddy rice')
) AS v(name, step_order, description)
WHERE p.process_name = 'Organic Hom Mali rice cultivation';

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT p.process_id, v.name, v.step_order, v.description
FROM process p
CROSS JOIN (VALUES
 ('Cleaning and pre-treatment', 1, 'Removal of impurities before milling'),
 ('Husking', 2, 'Removal of the rice husk to obtain brown rice'),
 ('Whitening', 3, 'Removal of bran layers to obtain milled rice')
) AS v(name, step_order, description)
WHERE p.process_name = 'Hom Mali rice milling';

-- Material flows
INSERT INTO flow (flow_name, flow_type, material_id, unit_id)
SELECT material_name, 'INPUT', material_id, unit_id
FROM material;

-- Water flow
INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT 'Rainwater', 'INPUT', unit_id
FROM unit WHERE unit_symbol = 'm3';

-- Regional combined fertilizer flow (source reports pellet + liquid together)
INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT 'Organic fertilizer (pellet and liquid)', 'INPUT', unit_id
FROM unit WHERE unit_symbol = 'kg';

-- Product output flows for all registered products
INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT p.product_name, 'OUTPUT', p.product_id, p.unit_id
FROM product p;

-- Emission and water-emission flow catalog (13 distinct flows from Table 6)
INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT v.name, v.flow_type, u.unit_id
FROM (VALUES
 ('Methane (rice field)', 'EMISSION'),
 ('Nitrous oxide (direct)', 'EMISSION'),
 ('Nitrous oxide (indirect volatilization)', 'EMISSION'),
 ('Nitrous oxide (leaching and runoff)', 'EMISSION'),
 ('Carbon dioxide (fossil fuel combustion)', 'EMISSION'),
 ('Methane (fossil fuel combustion)', 'EMISSION'),
 ('Nitrogen dioxide (fossil fuel combustion)', 'EMISSION'),
 ('Sulfur dioxide (fossil fuel combustion)', 'EMISSION'),
 ('Carbon monoxide (fossil fuel combustion)', 'EMISSION'),
 ('Non-methane volatile organic compounds (fossil fuel combustion)', 'EMISSION'),
 ('Nitrous oxide (fossil fuel combustion)', 'EMISSION'),
 ('Total nitrogen', 'WATER_EMISSION'),
 ('Total phosphorus', 'WATER_EMISSION')
) AS v(name, flow_type)
JOIN unit u ON u.unit_symbol = 'kg';

-- Production batches:
-- NE7 Surin: 211 ha, 2,929 kg/ha = 618,019 kg calculated output.
-- Northeast regional average: 1 ha reference basis, 2,946 kg/ha.
INSERT INTO production_batch
(product_id, production_date, production_quantity, unit_id,
 location_id, production_year, area_ha)
SELECT
    p.product_id, NULL, v.quantity, u.unit_id, l.location_id, 2017, v.area
FROM (VALUES
 ('Surin', 618019::numeric, 211::numeric),
 ('Northeast Thailand (Regional Average)', 2946::numeric, 1::numeric)
) AS v(location_name, quantity, area)
JOIN location l ON l.province = v.location_name
JOIN product p ON p.product_name = 'Organic Hom Mali paddy rice (KDML 105)'
JOIN unit u ON u.unit_symbol = 'kg';

-- One aggregated crop-cycle process per cultivation batch
INSERT INTO batch_process
(batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, 1, b.location_id
FROM production_batch b
JOIN process p
  ON p.process_name = 'Organic Hom Mali rice cultivation'
JOIN process_step ps
  ON ps.process_id = p.process_id
 AND ps.step_order = 2;

-- LCI exchanges: Table 5 values
-- Surin NE7 values multiplied by 211 ha.
-- Northeast regional average values are per 1 ha.
INSERT INTO lci_exchange
(batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id, f.flow_id, v.exchange_type, v.amount,
       u.unit_id, ds.source_id, 2017
FROM (VALUES
 ('Surin', 'Rice seed', 'INPUT', 26375::numeric, 'kg'),
 ('Surin', 'Manure (green and cattle)', 'INPUT', 86088::numeric, 'kg'),
 ('Surin', 'Compost', 'INPUT', 355324::numeric, 'kg'),
 ('Surin', 'Organic fertilizer (pellet)', 'INPUT', 633::numeric, 'kg'),
 ('Surin', 'Organic fertilizer (liquid)', 'INPUT', 211::numeric, 'kg'),
 ('Surin', 'Rainwater', 'INPUT', 2930790::numeric, 'm3'),
 ('Surin', 'Organic Hom Mali paddy rice (KDML 105)', 'OUTPUT', 618019::numeric, 'kg'),
 ('Northeast Thailand (Regional Average)', 'Rice seed', 'INPUT', 117::numeric, 'kg'),
 ('Northeast Thailand (Regional Average)', 'Manure (green and cattle)', 'INPUT', 754::numeric, 'kg'),
 ('Northeast Thailand (Regional Average)', 'Compost', 'INPUT', 990::numeric, 'kg'),
 ('Northeast Thailand (Regional Average)', 'Organic fertilizer (pellet and liquid)', 'INPUT', 394::numeric, 'kg'),
 ('Northeast Thailand (Regional Average)', 'Diesel', 'INPUT', 39::numeric, 'L'),
 ('Northeast Thailand (Regional Average)', 'Rainwater', 'INPUT', 13413::numeric, 'm3'),
 ('Northeast Thailand (Regional Average)', 'Organic Hom Mali paddy rice (KDML 105)', 'OUTPUT', 2946::numeric, 'kg')
) AS v(location_name, flow_name, exchange_type, amount, unit_symbol)
JOIN location l ON l.province = v.location_name
JOIN production_batch b ON b.location_id = l.location_id
JOIN batch_process bp ON bp.batch_id = b.batch_id
JOIN flow f ON f.flow_name = v.flow_name
JOIN unit u ON u.unit_symbol = v.unit_symbol
JOIN data_source ds
  ON ds.publication_year = 2020
 AND ds.document_name =
 'Life Cycle Assessment of Thai Hom Mali Rice to Support the Policy Decision on Organic Farming Area Expansion';

-- Table 6: Northeast regional average emissions per hectare.
-- Do not attribute these regional averages to the Surin NE7 batch.
INSERT INTO lci_exchange
(batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id, f.flow_id, 'OUTPUT', v.amount,
       u.unit_id, ds.source_id, 2017
FROM (VALUES
 ('Methane (rice field)', 45.8::numeric),
 ('Nitrous oxide (direct)', 0.200::numeric),
 ('Nitrous oxide (indirect volatilization)', 0.0133::numeric),
 ('Nitrous oxide (leaching and runoff)', 0.150::numeric),
 ('Carbon dioxide (fossil fuel combustion)', 105::numeric),
 ('Methane (fossil fuel combustion)', 0.0043::numeric),
 ('Nitrogen dioxide (fossil fuel combustion)', 0.0009::numeric),
 ('Sulfur dioxide (fossil fuel combustion)', 1.16::numeric),
 ('Carbon monoxide (fossil fuel combustion)', 0.0116::numeric),
 ('Non-methane volatile organic compounds (fossil fuel combustion)', 0.0577::numeric),
 ('Nitrous oxide (fossil fuel combustion)', 0.363::numeric),
 ('Total nitrogen', 8.48::numeric),
 ('Total phosphorus', 0.178::numeric)
) AS v(flow_name, amount)
JOIN location l ON l.province = 'Northeast Thailand (Regional Average)'
JOIN production_batch b ON b.location_id = l.location_id
JOIN batch_process bp ON bp.batch_id = b.batch_id
JOIN flow f ON f.flow_name = v.flow_name
JOIN unit u ON u.unit_symbol = 'kg'
JOIN data_source ds
  ON ds.publication_year = 2020
 AND ds.document_name =
 'Life Cycle Assessment of Thai Hom Mali Rice to Support the Policy Decision on Organic Farming Area Expansion';

-- Table 7: Northeast regional average environmental impacts per hectare.
INSERT INTO environment_impact
(batch_process_id, impact_type, impact_amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id, v.impact_type, v.amount, u.unit_id, ds.source_id, 2017
FROM (VALUES
 ('Global warming', 11400::numeric, 'kg CO2-eq'),
 ('Terrestrial acidification', 3.72::numeric, 'kg SO2-eq'),
 ('Freshwater eutrophication', 0.0270::numeric, 'kg PO4-eq'),
 ('Terrestrial ecotoxicity', 194::numeric, 'kg 1,4-DCB'),
 ('Freshwater ecotoxicity', 0.963::numeric, 'kg 1,4-DCB')
) AS v(impact_type, amount, unit_symbol)
JOIN location l ON l.province = 'Northeast Thailand (Regional Average)'
JOIN production_batch b ON b.location_id = l.location_id
JOIN batch_process bp ON bp.batch_id = b.batch_id
JOIN unit u ON u.unit_symbol = v.unit_symbol
JOIN data_source ds
  ON ds.publication_year = 2020
 AND ds.document_name =
 'Life Cycle Assessment of Thai Hom Mali Rice to Support the Policy Decision on Organic Farming Area Expansion';


-- Study-level impacts: Mungkung et al. (2020), Table 7.
-- Northeast Thailand regional average; functional unit: 1 kg paddy rice.
-- Values are reported per kg and are separate from the per-hectare
-- batch-level impacts stored in environment_impact.
INSERT INTO study_impact
(source_id, product_id, impact_type, impact_amount, unit_id,
 functional_unit_quantity, functional_unit_unit_id, location_id,
 impact_method, data_year, system_boundary, notes)
SELECT
    ds.source_id,
    p.product_id,
    v.impact_type,
    v.impact_amount,
    iu.unit_id,
    1,
    fu.unit_id,
    l.location_id,
    NULL,
    NULL,
    'Organic Hom Mali paddy rice cultivation; Northeast Thailand regional average; Table 7 result per 1 kg paddy rice.',
    'Mungkung et al. (2020), Table 7. Per-kg result. Assessment year and impact method are not assigned here because they are not specified in this table entry.'
FROM (VALUES
    ('Global warming', 3.86::numeric, 'kg CO2-eq'),
    ('Terrestrial acidification', 0.0012::numeric, 'kg SO2-eq'),
    ('Freshwater eutrophication', 0.00000917::numeric, 'kg PO4-eq'),
    ('Terrestrial ecotoxicity', 0.0658::numeric, 'kg 1,4-DCB'),
    ('Freshwater ecotoxicity', 0.0003::numeric, 'kg 1,4-DCB')
) AS v(impact_type, impact_amount, unit_symbol)
JOIN data_source ds
  ON ds.document_name =
     'Life Cycle Assessment of Thai Hom Mali Rice to Support the Policy Decision on Organic Farming Area Expansion'
JOIN product p
  ON p.product_name = 'Organic Hom Mali paddy rice (KDML 105)'
JOIN unit iu ON iu.unit_symbol = v.unit_symbol
JOIN unit fu ON fu.unit_symbol = 'kg'
JOIN location l
  ON l.province = 'Northeast Thailand (Regional Average)'
WHERE NOT EXISTS (
    SELECT 1
    FROM study_impact existing
    WHERE existing.source_id = ds.source_id
      AND existing.product_id = p.product_id
      AND existing.impact_type = v.impact_type
      AND existing.functional_unit_quantity = 1
      AND existing.functional_unit_unit_id = fu.unit_id
      AND existing.location_id = l.location_id
);

