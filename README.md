# Agri LCI · PostgreSQL

The complete multi-crop PostgreSQL schema and seed scripts are in `sql/`.

## Start the database

The Compose service initializes a **fresh** PostgreSQL volume from the schema and all crop seed scripts in `sql/`:

```powershell
docker compose up -d postgres
```

The init scripts run only when PostgreSQL creates an empty data volume. The app's current `.env` connects to `agri_lci_package_test`, which has already been loaded with the full dataset. The migration script `sql/migrate_maize_lci_split.sql` is intentionally excluded from fresh initialization; use it only for its documented upgrade case.

## Start the API and UI

1. Install dependencies with `npm install` (PostgreSQL driver: `pg`).
2. Start the API with `npm run server`. The API uses `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` from `.env` or `server/.env`.
3. Start Vite with `npm run dev`. The root `.env` selects live API mode and the Vite development proxy serves the API at `/api` and forwards requests to port 3001.

The UI displays products, production batches, locations, process steps, input/output flows, unit symbols, and linked data source citations returned by the API. See `update_package/README.md` for source scope, installation order, and data limitations.


## Full database update package

The complete multi-crop database schema, seed scripts, checks, audit, migration notes, installation order, data limitations, and references are in [update_package/README.md](update_package/README.md). The package SQL files are kept separate from the rice-only sql/ scripts used by the current Docker initialization. Review the package README before applying its scripts to a database.
