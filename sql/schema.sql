-- Agri LCI Database schema entry point.
-- Run from the project root using psql. Tables are created in domain schemas.
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS process;
CREATE SCHEMA IF NOT EXISTS production;
CREATE SCHEMA IF NOT EXISTS lci;
CREATE SCHEMA IF NOT EXISTS impact;
SET search_path TO core, catalog, process, production, lci, impact, public;
\ir schema/00_reference_data.sql
\ir schema/01_products_and_materials.sql
\ir schema/02_locations_and_sources.sql
\ir schema/03_processes.sql
\ir schema/04_batches_and_flows.sql
\ir schema/05_exchanges.sql
\ir schema/06_impacts_and_constraints.sql
