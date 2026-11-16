-- Run after schema.sql and seed.sql
SELECT 'product_category' AS table_name, COUNT(*) AS row_count FROM product_category
UNION ALL SELECT 'unit', COUNT(*) FROM unit
UNION ALL SELECT 'product', COUNT(*) FROM product
UNION ALL SELECT 'material', COUNT(*) FROM material
UNION ALL SELECT 'location', COUNT(*) FROM location
UNION ALL SELECT 'supplier', COUNT(*) FROM supplier
UNION ALL SELECT 'data_source', COUNT(*) FROM data_source
UNION ALL SELECT 'material_supplier', COUNT(*) FROM material_supplier
UNION ALL SELECT 'process', COUNT(*) FROM process
UNION ALL SELECT 'process_step', COUNT(*) FROM process_step
UNION ALL SELECT 'production_batch', COUNT(*) FROM production_batch
UNION ALL SELECT 'batch_process', COUNT(*) FROM batch_process
UNION ALL SELECT 'flow', COUNT(*) FROM flow
UNION ALL SELECT 'lci_exchange', COUNT(*) FROM lci_exchange
UNION ALL SELECT 'environment_impact', COUNT(*) FROM environment_impact
ORDER BY table_name;

-- Check expected key counts
SELECT
  (SELECT COUNT(*) FROM product) AS products_expected_6,
  (SELECT COUNT(*) FROM process) AS processes_expected_2,
  (SELECT COUNT(*) FROM process_step) AS steps_expected_6,
  (SELECT COUNT(*) FROM lci_exchange) AS lci_exchanges_expected_27,
  (SELECT COUNT(*) FROM environment_impact) AS impacts_expected_5;

-- Check broken foreign-key references (all should be zero)
SELECT 'lci_exchange_missing_batch_process' AS check_name, COUNT(*) AS failures
FROM lci_exchange e LEFT JOIN batch_process bp USING (batch_process_id)
WHERE bp.batch_process_id IS NULL
UNION ALL
SELECT 'impact_missing_batch_process', COUNT(*)
FROM environment_impact e LEFT JOIN batch_process bp USING (batch_process_id)
WHERE bp.batch_process_id IS NULL;
