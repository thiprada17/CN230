# Agri LCI Database

## Package contents

- `sql/schema.sql` — PostgreSQL schema (16 tables).
- `sql/seed.sql` — rice cultivation inventory, emissions, impact indicators, and rice master data.
- `sql/seed_cassava.sql` — cassava starch-processing inventory (Lerdlattaporn et al., 2021).
- `sql/seed_cassava_cultivation.sql` — cassava cultivation inventory, Northern Thailand weighted average (Kongboon, 2013; crop year 2011).
- `sql/seed_maize.sql` — Maize cultivation and separate IDEA v2.0 / ecoinvent v3.0 inventories.
- `sql/seed_rice_milling_unido.sql` — National rice-milling reference yields (UNIDO, 1980).
- `sql/seed_khomkaew_rice_milling.sql` — small-machine rice-milling trial (Khomkaew, 2022).
- `sql/seed_sugarcane.sql` — sugarcane cultivation, transport, and sugar production.
- `sql/seed_sugarcane_completion.sql` — additional sugarcane inventory data.
- `sql/seed_sugarcane_byproducts.sql` — sugarcane processing by-products.
- `sql/seed_pineapple.sql` — fresh pineapple cultivation and canned pineapple processing.
- `sql/seed_pineapple_byproducts.sql` — pineapple-processing by-products.
- `sql/check.sql` — basic database checks.
- `sql/audit_product_completeness.sql` — product-level batch, flow, exchange, input, and output audit.
- `sql/migrate_maize_lci_split.sql` — migration for an older database with the previous combined maize LCI step; not for fresh installation.

## Fresh database installation

Run on a fresh, empty database in this order:

1. `schema.sql`
2. `seed.sql`
3. `seed_khomkaew_rice_milling.sql`
4. `seed_rice_milling_unido.sql`
5. `seed_cassava.sql`
6. `seed_cassava_cultivation.sql`
7. `seed_maize.sql`
8. `seed_sugarcane.sql`
9. `seed_sugarcane_completion.sql`
10. `seed_sugarcane_byproducts.sql`
11. `seed_pineapple.sql`
12. `seed_pineapple_byproducts.sql`
13. `audit_product_completeness.sql`

`check.sql` checks the original base seed only; it is not a full-project validation script.

Do not run `migrate_maize_lci_split.sql` for a fresh installation. It is only for upgrading an older database with the previous combined maize LCI step.

## Installation commands (Mac + Docker)

Run from the project root on a fresh, empty test database. These commands target `agri_lci_package_test`, not the main database `agri_lci`.

```bash
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/schema.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_khomkaew_rice_milling.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_rice_milling_unido.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_cassava.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_cassava_cultivation.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_maize.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_sugarcane.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_sugarcane_completion.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_sugarcane_byproducts.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_pineapple.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/seed_pineapple_byproducts.sql
docker exec -i agri_lci_postgres psql -U agri_admin -d agri_lci_package_test -v ON_ERROR_STOP=1 < update_package/sql/audit_product_completeness.sql
```

Run this sequence only once on an empty database. Do not rerun seed scripts on a populated database without checking their behavior first.


## Data scope and limitations

- Rice: Table 6 emissions and Table 7 impact indicators from Mungkung et al. (2020) are attached only to the Northeast Thailand regional-average cultivation batch, not the Surin batch.
- Cassava processing: gate-to-gate factory case, functional unit 1,000 kg native tapioca starch at 0% water content. The reported 636 kg CO2-eq is a study-reported GHG result, not a complete LCIA profile.
- Cassava cultivation: Northern Thailand weighted average for crop year 2011; reported yield 22,906.25 kg/ha.
- Maize: 2016 field-survey inventories for Mae Chaem and Chiang Dao. Table 4 uses a 1 kg maize-grain functional unit; IDEA and ecoinvent inventories remain separate.
- UNIDO rice milling: national reference yields, not a regional or plant-specific inventory.
- Khomkaew milling: the 12.1% moisture trial reports 10 kg input and 9.45 kg outputs. The 0.55 kg difference is unaccounted for and has not been estimated.
- Sugarcane: cultivation, transport, and sugar-production inventories are based on Nawapanan et al. (2022), drawing on data from 15 Thai sugar factories during 2016–2019. The by-product inventory is based on Makul and Sua-iam (2016). The source contains differences between its table and narrative for transport diesel and functional-unit descriptions; consult the SQL source comments before comparing values.

- Pineapple: fresh-fruit cultivation inventories distinguish small-, medium-, and large-farm scenarios, with a separate overall average. Canned-pineapple impacts use a functional unit of one 30 oz can. National processing by-product quantities are based on Hemung et al. (2022), using 2020 supply data; this is a partial by-product model, not a complete factory inventory.

- Missing source values, years, locations, and impacts are not invented. Review source notes and audit results before interpreting missing data as zero.

## References

1. Mungkung et al. (2019): https://doi.org/10.1016/j.jclepro.2018.11.197
2. Mungkung et al. (2020): https://doi.org/10.3390/su12156003
3. Lerdlattaporn et al. (2021): https://doi.org/10.1186/s42834-021-00093-9
4. Kongboon (2013), Chiang Mai University thesis: https://archive.lib.cmu.ac.th/full/T/2013/enen40513rk_ch4.pdf
5. Supasri et al. (2020): https://doi.org/10.1038/s41598-020-60532-2
6. Supasri et al. (2021), correction: https://doi.org/10.1038/s41598-021-03592-2
7. UNIDO (1980): https://downloads.unido.org/ot/47/89/4789442/10001-15000_10014.pdf
8. Khomkaew (2022): https://ph02.tci-thaijo.org/index.php/sej/article/view/245528

9. Nawapanan et al. (2022), *Green GDP Indicator with Application to Life Cycle of Sugar Industry in Thailand*: https://doi.org/10.3390/su14020918

10. Makul and Sua-iam (2016), *Characteristics and utilization of sugarcane filter cake waste in the production of lightweight foamed concrete*: https://doi.org/10.1016/j.jclepro.2016.02.111

11. Usubharatana and Phungrassami (2017), *Evaluation of opportunities to reduce the carbon footprint of fresh and canned pineapple processing in central Thailand*: https://doi.org/10.15244/pjoes/69442

12. Hemung et al. (2022), *A study of the potential of by-products from pineapple processing in Thailand: Review article*: https://doi.org/10.53730/ijhs.v6nS4.12131

## Sharing

Share the complete `update_package` folder, including this README and all files in `update_package/sql/`.
