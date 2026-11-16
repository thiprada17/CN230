SET search_path TO core, catalog, process, production, lci, impact, public;
-- 1. Audit products, their own batches and environmental impacts
SELECT
    p.product_name,
    COUNT(DISTINCT b.batch_id) AS own_batches,
    COUNT(DISTINCT bp.batch_process_id) AS process_stages,
    COUNT(DISTINCT e.exchange_id) AS batch_exchanges,
    COUNT(DISTINCT CASE WHEN e.exchange_type = 'INPUT'
        THEN e.exchange_id END) AS inputs,
    COUNT(DISTINCT CASE WHEN e.exchange_type = 'OUTPUT'
        THEN e.exchange_id END) AS outputs,
    COUNT(DISTINCT ei.impact_id) AS environmental_impacts
FROM product p
LEFT JOIN production_batch b
    ON b.product_id = p.product_id
LEFT JOIN batch_process bp
    ON bp.batch_id = b.batch_id
LEFT JOIN lci_exchange e
    ON e.batch_process_id = bp.batch_process_id
LEFT JOIN environment_impact ei
    ON ei.batch_process_id = bp.batch_process_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_name;

-- 2. Audit product flows, including by-products
SELECT
    p.product_name,
    f.flow_name,
    f.flow_type,
    u.unit_name,
    e.exchange_type,
    e.amount,
    e.data_year,
    ds.organization_name,
    ds.document_name,
    ds.publication_year,
    ds.reference_url
FROM product p
LEFT JOIN flow f
    ON f.product_id = p.product_id
LEFT JOIN unit u
    ON u.unit_id = f.unit_id
LEFT JOIN lci_exchange e
    ON e.flow_id = f.flow_id
LEFT JOIN data_source ds
    ON ds.source_id = e.source_id
ORDER BY p.product_name, f.flow_name, e.exchange_type;

-- 3. Audit all registered sources
SELECT
    source_id,
    organization_name,
    document_name,
    publication_year,
    reference_url
FROM data_source
ORDER BY source_id;

