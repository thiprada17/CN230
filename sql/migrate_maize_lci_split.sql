SET search_path TO core, catalog, process, production, lci, impact, public;

BEGIN;

-- Rename step 7 as the IDEA v2.0 inventory.
UPDATE process_step ps
SET step_name = 'Whole-system LCI - IDEA v2.0 (functional unit: 1 kg maize grain)',
    description = 'Aggregated whole-system inventory from Table 4 using IDEA v2.0, reported per 1 kg maize grain.'
FROM process p
WHERE ps.process_id = p.process_id
  AND p.process_name = 'Maize cultivation (Northern Thailand)'
  AND ps.step_order = 7;

-- Add the separate ecoinvent v3.0 step.
INSERT INTO process_step (process_id, step_name, step_order, description)
SELECT p.process_id,
       'Whole-system LCI - ecoinvent v3.0 (functional unit: 1 kg maize grain)',
       8,
       'Aggregated whole-system inventory from Table 4 using ecoinvent v3.0, reported per 1 kg maize grain.'
FROM process p
WHERE p.process_name = 'Maize cultivation (Northern Thailand)'
  AND NOT EXISTS (
      SELECT 1 FROM process_step ps
      WHERE ps.process_id = p.process_id AND ps.step_order = 8
  );

-- Create a second batch_process for each district's ecoinvent inventory.
INSERT INTO batch_process (batch_id, step_id, execution_order, location_id)
SELECT bp.batch_id, ps8.step_id, 8, bp.location_id
FROM batch_process bp
JOIN process_step ps7 ON ps7.step_id = bp.step_id AND ps7.step_order = 7
JOIN process_step ps8 ON ps8.process_id = ps7.process_id AND ps8.step_order = 8
JOIN production_batch b ON b.batch_id = bp.batch_id
JOIN product p ON p.product_id = b.product_id
WHERE p.product_name = 'Maize grain'
  AND b.production_quantity = 1
  AND b.area_ha IS NULL
  AND b.production_year = 2016
  AND NOT EXISTS (
      SELECT 1 FROM batch_process existing
      WHERE existing.batch_id = bp.batch_id
        AND existing.step_id = ps8.step_id
  );

-- Move only ecoinvent exchanges to the new ecoinvent process step.
UPDATE lci_exchange e
SET batch_process_id = bp8.batch_process_id
FROM batch_process bp7
JOIN process_step ps7 ON ps7.step_id = bp7.step_id AND ps7.step_order = 7
JOIN batch_process bp8 ON bp8.batch_id = bp7.batch_id
JOIN process_step ps8 ON ps8.step_id = bp8.step_id AND ps8.step_order = 8
JOIN production_batch b ON b.batch_id = bp7.batch_id
JOIN product p ON p.product_id = b.product_id
JOIN data_source ds ON ds.document_name =
    'Supasri et al. (2020) - Table 4 LCI using ecoinvent v3.0'
WHERE e.batch_process_id = bp7.batch_process_id
  AND e.source_id = ds.source_id
  AND p.product_name = 'Maize grain'
  AND b.production_quantity = 1
  AND b.area_ha IS NULL
  AND b.production_year = 2016;

-- Abort unless all four district/database groups contain exactly 10
-- exchanges from the correct source.
DO $$
DECLARE
    group_count integer;
    bad_count integer;
BEGIN
    SELECT COUNT(*)
    INTO group_count
    FROM batch_process bp
    JOIN process_step ps ON ps.step_id = bp.step_id
    JOIN production_batch b ON b.batch_id = bp.batch_id
    JOIN product p ON p.product_id = b.product_id
    WHERE p.product_name = 'Maize grain'
      AND b.production_quantity = 1
      AND b.area_ha IS NULL
      AND b.production_year = 2016
      AND ps.step_order IN (7, 8);

    IF group_count <> 4 THEN
        RAISE EXCEPTION 'Expected 4 maize LCI groups, found %', group_count;
    END IF;

    SELECT COUNT(*)
    INTO bad_count
    FROM (
        SELECT
            bp.batch_process_id,
            ps.step_order,
            COUNT(e.exchange_id) AS exchange_count,
            COUNT(e.exchange_id) FILTER (
                WHERE ds.document_name =
                    CASE ps.step_order
                        WHEN 7 THEN 'Supasri et al. (2020) - Table 4 LCI using IDEA v2.0'
                        WHEN 8 THEN 'Supasri et al. (2020) - Table 4 LCI using ecoinvent v3.0'
                    END
            ) AS correct_source_count
        FROM batch_process bp
        JOIN process_step ps ON ps.step_id = bp.step_id
        JOIN production_batch b ON b.batch_id = bp.batch_id
        JOIN product p ON p.product_id = b.product_id
        LEFT JOIN lci_exchange e ON e.batch_process_id = bp.batch_process_id
        LEFT JOIN data_source ds ON ds.source_id = e.source_id
        WHERE p.product_name = 'Maize grain'
          AND b.production_quantity = 1
          AND b.area_ha IS NULL
          AND b.production_year = 2016
          AND ps.step_order IN (7, 8)
        GROUP BY bp.batch_process_id, ps.step_order
        HAVING COUNT(e.exchange_id) <> 10
            OR COUNT(e.exchange_id) FILTER (
                WHERE ds.document_name =
                    CASE ps.step_order
                        WHEN 7 THEN 'Supasri et al. (2020) - Table 4 LCI using IDEA v2.0'
                        WHEN 8 THEN 'Supasri et al. (2020) - Table 4 LCI using ecoinvent v3.0'
                    END
            ) <> 10
    ) invalid_groups;

    IF bad_count <> 0 THEN
        RAISE EXCEPTION 'Maize LCI validation failed for % groups', bad_count;
    END IF;
END $$;

COMMIT;

