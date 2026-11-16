-- Add national dry-season rice production as a product with annual batches.
-- This is a production-statistics dataset, not a complete cultivation LCI.
BEGIN;
SET search_path TO core, catalog, process, production, lci, impact, public;

INSERT INTO core.data_source
  (organization_name, document_name, publication_year, reference_url, access_date)
SELECT 'Office of Agricultural Economics (OAE)',
       'Rice dry-season production quantity (national), imported CSV records',
       2025,
       'https://www.oae.go.th/',
       CURRENT_DATE
WHERE NOT EXISTS (
  SELECT 1 FROM core.data_source
  WHERE document_name = 'Rice dry-season production quantity (national), imported CSV records'
);

INSERT INTO catalog.product (product_name, category_id, description, unit_id)
SELECT 'Thai dry-season rice (national statistics)', c.category_id,
       'National annual dry-season rice production series. Production statistics only; not a complete life-cycle inventory.',
       u.unit_id
FROM catalog.product_category c
JOIN core.unit u ON u.unit_symbol = 't'
WHERE c.category_name = 'National rice statistics'
  AND NOT EXISTS (
    SELECT 1 FROM catalog.product p
    WHERE p.product_name = 'Thai dry-season rice (national statistics)'
  );

INSERT INTO process.process (process_name, description)
SELECT 'National dry-season rice production reporting',
       'Annual national output statistics reported in the imported source dataset; no cultivation inputs or environmental impacts are inferred.'
WHERE NOT EXISTS (
  SELECT 1 FROM process.process
  WHERE process_name = 'National dry-season rice production reporting'
);

INSERT INTO process.process_step (process_id, step_name, step_order, description)
SELECT p.process_id, 'Annual reported production output', 1,
       'Reported total dry-season rice production for the crop year.'
FROM process.process p
WHERE p.process_name = 'National dry-season rice production reporting'
  AND NOT EXISTS (
    SELECT 1 FROM process.process_step ps
    WHERE ps.process_id = p.process_id AND ps.step_order = 1
  );

INSERT INTO lci.flow (flow_name, flow_type, product_id, unit_id)
SELECT p.product_name, 'OUTPUT', p.product_id, p.unit_id
FROM catalog.product p
WHERE p.product_name = 'Thai dry-season rice (national statistics)'
  AND NOT EXISTS (
    SELECT 1 FROM lci.flow f
    WHERE f.product_id = p.product_id AND f.flow_type = 'OUTPUT'
  );

INSERT INTO production.production_batch
  (product_id, production_quantity, unit_id, location_id, production_year)
SELECT p.product_id,
       (r.raw_data->>'values')::numeric,
       tonne.unit_id,
       loc.location_id,
       (r.raw_data->>'year')::integer - 543
FROM lci.raw_record r
JOIN catalog.product p
  ON p.product_name = 'Thai dry-season rice (national statistics)'
JOIN core.unit tonne ON tonne.unit_symbol = 't'
JOIN core.location loc
  ON loc.province = 'Thailand (national statistics)' AND loc.country = 'Thailand'
WHERE r.source_file = 'Rice dry-season production quantity (national).csv'
  AND r.raw_data->>'attribute' = 'yield'
  AND r.raw_data->>'unit' = 'tonnes'
  AND NOT EXISTS (
    SELECT 1 FROM production.production_batch existing
    WHERE existing.product_id = p.product_id
      AND existing.production_year = (r.raw_data->>'year')::integer - 543
      AND existing.location_id = loc.location_id
  );

INSERT INTO production.batch_process
  (batch_id, step_id, execution_order, location_id)
SELECT b.batch_id, ps.step_id, 1, b.location_id
FROM production.production_batch b
JOIN catalog.product p ON p.product_id = b.product_id
JOIN process.process pr
  ON pr.process_name = 'National dry-season rice production reporting'
JOIN process.process_step ps ON ps.process_id = pr.process_id AND ps.step_order = 1
WHERE p.product_name = 'Thai dry-season rice (national statistics)'
  AND NOT EXISTS (
    SELECT 1 FROM production.batch_process existing
    WHERE existing.batch_id = b.batch_id AND existing.step_id = ps.step_id
  );

INSERT INTO lci.lci_exchange
  (batch_process_id, flow_id, exchange_type, amount, unit_id, source_id, data_year)
SELECT bp.batch_process_id, f.flow_id, 'OUTPUT', b.production_quantity,
       b.unit_id, ds.source_id, b.production_year
FROM production.production_batch b
JOIN catalog.product p ON p.product_id = b.product_id
JOIN production.batch_process bp ON bp.batch_id = b.batch_id
JOIN process.process_step ps ON ps.step_id = bp.step_id AND ps.step_name = 'Annual reported production output'
JOIN lci.flow f ON f.product_id = p.product_id AND f.flow_type = 'OUTPUT'
JOIN core.data_source ds
  ON ds.document_name = 'Rice dry-season production quantity (national), imported CSV records'
WHERE p.product_name = 'Thai dry-season rice (national statistics)'
  AND NOT EXISTS (
    SELECT 1 FROM lci.lci_exchange existing
    WHERE existing.batch_process_id = bp.batch_process_id
      AND existing.flow_id = f.flow_id
      AND existing.exchange_type = 'OUTPUT'
  );

COMMIT;
