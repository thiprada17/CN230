-- Move existing public tables into domain schemas without deleting data.
BEGIN;

CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS process;
CREATE SCHEMA IF NOT EXISTS production;
CREATE SCHEMA IF NOT EXISTS lci;
CREATE SCHEMA IF NOT EXISTS impact;

ALTER TABLE IF EXISTS public.unit SET SCHEMA core;
ALTER TABLE IF EXISTS public.location SET SCHEMA core;
ALTER TABLE IF EXISTS public.data_source SET SCHEMA core;

ALTER TABLE IF EXISTS public.product_category SET SCHEMA catalog;
ALTER TABLE IF EXISTS public.product SET SCHEMA catalog;
ALTER TABLE IF EXISTS public.material SET SCHEMA catalog;
ALTER TABLE IF EXISTS public.supplier SET SCHEMA catalog;
ALTER TABLE IF EXISTS public.material_supplier SET SCHEMA catalog;

ALTER TABLE IF EXISTS public.process SET SCHEMA process;
ALTER TABLE IF EXISTS public.process_step SET SCHEMA process;

ALTER TABLE IF EXISTS public.production_batch SET SCHEMA production;
ALTER TABLE IF EXISTS public.batch_process SET SCHEMA production;

ALTER TABLE IF EXISTS public.flow SET SCHEMA lci;
ALTER TABLE IF EXISTS public.lci_exchange SET SCHEMA lci;

ALTER TABLE IF EXISTS public.environment_impact SET SCHEMA impact;
ALTER TABLE IF EXISTS public.study_impact SET SCHEMA impact;

COMMIT;

SET search_path TO core, catalog, process, production, lci, impact, public;
