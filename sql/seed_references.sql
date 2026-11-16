SET search_path TO core, catalog, process, production, lci, impact, public;
-- Supplementary references provided for the LCI Atlas source directory.
-- These entries document related literature; they do not reassign provenance
-- for existing exchange or impact measurements.
BEGIN;

INSERT INTO data_source
    (organization_name, document_name, publication_year, reference_url, access_date)
SELECT v.organization_name, v.document_name, v.publication_year, v.reference_url, CURRENT_DATE
FROM (VALUES
    ('The Nation Thailand', 'TGO sets new emission factors for electricity generation and transmission', 2025, 'https://www.nationthailand.com/news/policy/40059019'),
    ('Ekasilp, Soponronarit and Therdyothin', 'Energy Analysis in Rice Mills for Cogeneration in Thailand', 1995, 'https://li01.tci-thaijo.org/index.php/anres/article/view/241279'),
    ('Yodkhum, Sampattagul and Gheewala', 'Energy and environmental impact analysis of rice cultivation and straw management in northern Thailand', 2018, 'https://doi.org/10.1007/s11356-018-1961-y'),
    ('Usubharatana and Phungrassami', 'Evaluation of Opportunities to Reduce the Carbon Footprint of Fresh and Canned Pineapple Processing in Central Thailand', 2017, 'https://doi.org/10.15244/pjoes/69442'),
    ('Drosou et al.', 'Life Cycle Assessment of the Canned Fruits Industry: Sustainability through Waste Valorization and Implementation of Innovative Techniques', 2023, 'https://www.mdpi.com/2624-7402/5/1/26')
) AS v(organization_name, document_name, publication_year, reference_url)
WHERE NOT EXISTS (
    SELECT 1
    FROM data_source existing
    WHERE existing.reference_url = v.reference_url
);

COMMIT;

