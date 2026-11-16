-- Cassava processing inventory
-- Lerdlattaporn et al. (2021), Table 1, Scenario 1
-- Functional unit: 1,000 kg starch at 0% water content
-- Gate-to-gate; factory data from Northeast Thailand, 2018.

-- Normalize existing rice source URLs in this test database.
UPDATE data_source
SET reference_url = 'https://doi.org/10.1016/j.jclepro.2018.11.197'
WHERE publication_year = 2019
  AND document_name LIKE 'Life Cycle Assessment of Thai organic Hom Mali rice%';

UPDATE data_source
SET reference_url = 'https://doi.org/10.3390/su12156003'
WHERE publication_year = 2020
  AND document_name LIKE 'Life Cycle Assessment of Thai Hom Mali Rice%';

UPDATE data_source
SET reference_url = 'https://ph02.tci-thaijo.org/index.php/sej/article/view/245528'
WHERE publication_year = 2022
  AND document_name LIKE 'Effect of Paddy Moisture Content%';

-- Additional unit: dry-basis mass.
INSERT INTO unit (unit_name, unit_symbol, unit_type)
VALUES ('Kilogram dry basis', 'kg dry', 'mass');

-- Product category.
INSERT INTO product_category (category_name, description)
VALUES (
  'Cassava and tapioca starch products',
  'Cassava root, native tapioca starch and processing by-products'
);

-- Location: province not disclosed by the study.
INSERT INTO location (province, country)
VALUES ('Northeast Thailand (factory case study; province not specified)', 'Thailand');

-- Primary source.
INSERT INTO data_source
(organization_name, document_name, publication_year, reference_url, access_date)
VALUES (
  'Lerdlattaporn et al.',
  'Implementing circular economy concept by converting cassava pulp and wastewater to biogas for sustainable production in starch industry',
  2021,
  'https://doi.org/10.1186/s42834-021-00093-9',
  CURRENT_DATE
);

-- Products.
INSERT INTO product (product_name, category_id, description, unit_id)
SELECT v.name, c.category_id, v.description, u.unit_id
FROM (VALUES
  ('Fresh cassava root',
   'Raw agricultural commodity; no fresh-weight production quantity added from this factory inventory',
   'kg'),
  ('Native tapioca starch (0% water content)',
   'Main product; reference functional unit is 1,000 kg at 0% water content',
   'kg'),
  ('Cassava pulp (dry basis)',
   'Processing by-product; quantity reported on a dry basis',
   'kg dry'),
  ('Cassava peel (dry basis)',
   'Processing by-product; quantity reported on a dry basis',
   'kg dry')
) AS v(name, description, symbol)
JOIN product_category c
  ON c.category_name = 'Cassava and tapioca starch products'
JOIN unit u ON u.unit_symbol = v.symbol;

-- Materials and resources.
INSERT INTO material (material_name, material_type, unit_id, description)
SELECT v.name, v.type, u.unit_id, v.description
FROM (VALUES
  ('Cassava root (dry basis)', 'Raw material', 'kg dry',
   'Cassava root input reported on a dry basis'),
  ('Fresh water', 'Water resource', 'm3',
   'Fresh water used in starch production'),
  ('Processing chemical (unspecified)', 'Chemical', 'kg',
   'Generic chemical input; chemical identity not specified in Table 1'),
  ('Grid electricity', 'Energy', 'kWh',
   'Electricity consumed in starch production'),
  ('Fuel oil', 'Fuel', 'm3',
   'Fuel oil consumed in starch production'),
  ('Rhizome (dry basis)', 'Processing waste', 'kg dry',
   'Cassava rhizome waste reported on a dry basis'),
  ('Sand and soil (dry basis)', 'Processing waste', 'kg dry',
   'Sand and soil removed during processing, dry basis')
) AS v(name, type, symbol, description)
JOIN unit u ON u.unit_symbol = v.symbol;

-- Process and aggregated process step.
INSERT INTO process (process_name, description)
VALUES (
  'Native tapioca starch production (Scenario 1)',
  'Gate-to-gate factory inventory without an integrated biogas system; Northeast Thailand; 2018'
);

INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT p.process_id,
       'Aggregated starch production',
       1,
       'Aggregated Table 1 inventory normalized to 1,000 kg starch at 0% water content; not a physical production lot. Table 1 reports wastewater 19.2 m3 and COD concentration 12,200 g/m3. Article narrative also mentions 19.6 m3; the Table 1 value is used here.'
FROM process p
WHERE p.process_name = 'Native tapioca starch production (Scenario 1)';

-- Input material flows.
INSERT INTO flow (flow_name, flow_type, material_id, unit_id)
SELECT m.material_name, 'INPUT', m.material_id, m.unit_id
FROM material m
WHERE m.material_name IN (
  'Cassava root (dry basis)',
  'Fresh water',
  'Processing chemical (unspecified)',
  'Grid electricity',
  'Fuel oil'
);

-- Output waste flows.
INSERT INTO flow (flow_name, flow_type, material_id, unit_id)
SELECT m.material_name, 'OUTPUT', m.material_id, m.unit_id
FROM material m
WHERE m.material_name IN (
  'Rhizome (dry basis)',
  'Sand and soil (dry basis)'
);

-- Product output flows.
INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
SELECT p.product_name, 'OUTPUT', p.product_id, p.unit_id
FROM product p
WHERE p.product_name IN (
  'Native tapioca starch (0% water content)',
  'Cassava pulp (dry basis)',
  'Cassava peel (dry basis)'
);

-- Wastewater output.
INSERT INTO flow (flow_name, flow_type, unit_id)
SELECT 'Wastewater to final open lagoons', 'OUTPUT', unit_id
FROM unit WHERE unit_symbol = 'm3';

-- Reference batch: 1,000 kg starch is the study's functional unit,
-- not a claim that the factory produced only 1,000 kg.
INSERT INTO production_batch
(product_id, production_quantity, unit_id, location_id, production_year)
SELECT p.product_id, 1000, u.unit_id, l.location_id, 2018
FROM product p
JOIN unit u ON u.unit_symbol = 'kg'
JOIN location l
  ON l.province = 'Northeast Thailand (factory case study; province not specified)'
WHERE p.product_name = 'Native tapioca starch (0% water content)';

INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, 1, b.location_id
FROM production_batch b
JOIN product p ON p.product_id = b.product_id
JOIN process_step ps ON ps.step_name = 'Aggregated starch production'
JOIN process pr ON pr.process_id = ps.process_id
WHERE p.product_name = 'Native tapioca starch (0% water content)'
  AND pr.process_name = 'Native tapioca starch production (Scenario 1)';

-- Table 1 exchanges, Scenario 1, per 1,000 kg starch.
-- COD is a concentration, not a mass-per-functional-unit exchange,
-- so it is documented above and not inserted as an LCI exchange.
INSERT INTO lci_exchange
(batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id, f.flow_id, v.exchange_type, v.amount,
       u.unit_id, ds.source_id, 2018
FROM (VALUES
  ('Cassava root (dry basis)', 'INPUT', 1560::numeric, 'kg dry'),
  ('Fresh water', 'INPUT', 16.7::numeric, 'm3'),
  ('Processing chemical (unspecified)', 'INPUT', 0.26::numeric, 'kg'),
  ('Grid electricity', 'INPUT', 197.8::numeric, 'kWh'),
  ('Fuel oil', 'INPUT', 0.0452::numeric, 'm3'),
  ('Native tapioca starch (0% water content)', 'OUTPUT', 1000::numeric, 'kg'),
  ('Cassava pulp (dry basis)', 'OUTPUT', 1550::numeric, 'kg dry'),
  ('Cassava peel (dry basis)', 'OUTPUT', 50::numeric, 'kg dry'),
  ('Rhizome (dry basis)', 'OUTPUT', 530::numeric, 'kg dry'),
  ('Sand and soil (dry basis)', 'OUTPUT', 400::numeric, 'kg dry'),
  ('Wastewater to final open lagoons', 'OUTPUT', 19.2::numeric, 'm3')
) AS v(flow_name, exchange_type, amount, unit_symbol)
JOIN flow f
  ON f.flow_name = v.flow_name
 AND f.flow_type = v.exchange_type
JOIN unit u ON u.unit_symbol = v.unit_symbol
JOIN data_source ds
  ON ds.document_name =
     'Implementing circular economy concept by converting cassava pulp and wastewater to biogas for sustainable production in starch industry'
JOIN batch_process bp ON TRUE
JOIN production_batch b ON b.batch_id = bp.batch_id
JOIN product p ON p.product_id = b.product_id
JOIN process_step ps ON ps.step_id = bp.step_id
JOIN process pr ON pr.process_id = ps.process_id
WHERE p.product_name = 'Native tapioca starch (0% water content)'
  AND pr.process_name = 'Native tapioca starch production (Scenario 1)';

-- Reported total GHG emissions; not a complete LCIA impact assessment.
INSERT INTO environment_impact
(batch_process_id, impact_type, impact_amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id,
       'Reported total GHG emissions (gate-to-gate, Scenario 1)',
       636.0,
       u.unit_id,
       ds.source_id,
       2018
FROM batch_process bp
JOIN production_batch b ON b.batch_id = bp.batch_id
JOIN product p ON p.product_id = b.product_id
JOIN process_step ps ON ps.step_id = bp.step_id
JOIN process pr ON pr.process_id = ps.process_id
JOIN unit u ON u.unit_symbol = 'kg CO2-eq'
JOIN data_source ds
  ON ds.document_name =
     'Implementing circular economy concept by converting cassava pulp and wastewater to biogas for sustainable production in starch industry'
WHERE p.product_name = 'Native tapioca starch (0% water content)'
  AND pr.process_name = 'Native tapioca starch production (Scenario 1)';
