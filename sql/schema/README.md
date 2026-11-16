# Database schema files

The database uses separate PostgreSQL namespaces:

| Schema | Tables |
| --- | --- |
| `core` | `unit`, `location`, `data_source` |
| `catalog` | `product_category`, `product`, `material`, `supplier`, `material_supplier` |
| `process` | `process`, `process_step` |
| `production` | `production_batch`, `batch_process` |
| `lci` | `flow`, `lci_exchange` |
| `impact` | `environment_impact`, `study_impact` |

`../schema.sql` is the fresh-database entry point. The numbered files contain the DDL by dependency group and create tables in their target schema.

For an existing database whose tables are currently in `public`, apply the data-preserving migration instead of rerunning the fresh schema:

```powershell
docker compose exec -T postgres psql -U agri_admin -d agri_lci -v ON_ERROR_STOP=1 -1 -f - < sql/migrate_public_to_schemas.sql
```

For a new database, initialize with the existing schema command:

```powershell
docker compose exec -T postgres psql -U agri_admin -d agri_lci -v ON_ERROR_STOP=1 -1 -f - < sql/schema.sql
```

The Compose service mounts the schema directory for both psql includes and PostgreSQL's first-run initialization.
