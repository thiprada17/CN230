-- Move previously imported raw records into the LCI namespace.
BEGIN;
CREATE SCHEMA IF NOT EXISTS lci;
DO $$
BEGIN
  IF to_regclass('staging.raw_record') IS NOT NULL
     AND to_regclass('lci.raw_record') IS NULL THEN
    ALTER TABLE staging.raw_record SET SCHEMA lci;
  END IF;
END $$;
COMMIT;
