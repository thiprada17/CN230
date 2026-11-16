BEGIN;

DO $$
DECLARE
    v_source_id INTEGER;
    v_location_id INTEGER;
    v_product_id INTEGER;
    v_process_id INTEGER;
    v_step_id INTEGER;
    v_batch_id INTEGER;
    v_batch_process_id INTEGER;
    v_kg_unit INTEGER;
    v_l_unit INTEGER;
    v_diesel_flow INTEGER;
    v_paraquat_flow INTEGER;
    v_n_flow INTEGER;
    v_p_flow INTEGER;
    v_k_flow INTEGER;
    v_ametine_flow INTEGER;
    v_flow_id INTEGER;
    v_flow_name TEXT;
    v_amount NUMERIC;
    v_unit_id INTEGER;
    v_exchange_type TEXT;
BEGIN
    SELECT unit_id INTO v_kg_unit FROM unit WHERE unit_symbol = 'kg';
    SELECT unit_id INTO v_l_unit FROM unit WHERE unit_symbol = 'L';

    IF v_kg_unit IS NULL OR v_l_unit IS NULL THEN
        RAISE EXCEPTION 'Required units kg or L are missing';
    END IF;

    -- Source: Kongboon (2013)
    SELECT source_id INTO v_source_id
    FROM data_source
    WHERE document_name =
        'Carbon and Water Footprints Evaluation of Bioethanol from Sugarcane and Cassava'
    LIMIT 1;

    IF v_source_id IS NULL THEN
        INSERT INTO data_source (
            organization_name, document_name, publication_year, reference_url
        )
        VALUES (
            'Ratchayuda Kongboon',
            'Carbon and Water Footprints Evaluation of Bioethanol from Sugarcane and Cassava',
            2013,
            'https://archive.lib.cmu.ac.th/full/T/2013/enen40513rk_ch4.pdf'
        )
        RETURNING source_id INTO v_source_id;
    END IF;

    -- Regional weighted-average cultivation location
    SELECT location_id INTO v_location_id
    FROM location
    WHERE country = 'Thailand'
      AND province = 'Northern Thailand (Weighted Average)'
      AND district IS NULL
    LIMIT 1;

    IF v_location_id IS NULL THEN
        INSERT INTO location (country, province, district)
        VALUES ('Thailand', 'Northern Thailand (Weighted Average)', NULL)
        RETURNING location_id INTO v_location_id;
    END IF;

    -- Product
    SELECT product_id INTO v_product_id
    FROM product
    WHERE product_name = 'Fresh cassava root'
    LIMIT 1;

    IF v_product_id IS NULL THEN
        RAISE EXCEPTION 'Fresh cassava root product was not found. Check seed_cassava.sql.';
    END IF;

    -- Process
    SELECT process_id INTO v_process_id
    FROM process
    WHERE process_name = 'Cassava cultivation (Northern Thailand weighted average)'
    LIMIT 1;

    IF v_process_id IS NULL THEN
        INSERT INTO process (process_name, description)
        VALUES (
            'Cassava cultivation (Northern Thailand weighted average)',
            'One-hectare weighted-average cassava cultivation inventory based on Kongboon (2013), Table 4.6. Survey data refer to the 2011 crop year. The study covers Nakhon Sawan, Kamphaeng Phet, and Uthai Thani. Nutrient quantities are recorded as reported; fertilizer formulations are not inferred.'
        )
        RETURNING process_id INTO v_process_id;
    END IF;

    -- Process step
    SELECT step_id INTO v_step_id
    FROM process_step
    WHERE process_id = v_process_id
      AND step_name = 'Cassava field cultivation'
    LIMIT 1;

    IF v_step_id IS NULL THEN
        INSERT INTO process_step (
            process_id, step_name, step_order, description
        )
        VALUES (
            v_process_id,
            'Cassava field cultivation',
            1,
            'Aggregate cultivation inventory per hectare from Table 4.6.'
        )
        RETURNING step_id INTO v_step_id;
    END IF;

    -- Production batch: 1 hectare, 2011 crop year
    SELECT batch_id INTO v_batch_id
    FROM production_batch
    WHERE product_id = v_product_id
      AND location_id = v_location_id
      AND production_year = 2011
      AND area_ha = 1
      AND production_quantity = 22906.25
    LIMIT 1;

    IF v_batch_id IS NULL THEN
        INSERT INTO production_batch (
            product_id, production_quantity, unit_id,
            location_id, production_year, area_ha
        )
        VALUES (
            v_product_id, 22906.25, v_kg_unit,
            v_location_id, 2011, 1
        )
        RETURNING batch_id INTO v_batch_id;
    END IF;

    -- Link batch to cultivation step
    SELECT batch_process_id INTO v_batch_process_id
    FROM batch_process
    WHERE batch_id = v_batch_id
      AND step_id = v_step_id
      AND execution_order = 1
    LIMIT 1;

    IF v_batch_process_id IS NULL THEN
        INSERT INTO batch_process (
            batch_id, step_id, execution_order, location_id
        )
        VALUES (
            v_batch_id, v_step_id, 1, v_location_id
        )
        RETURNING batch_process_id INTO v_batch_process_id;
    END IF;

    -- Ensure Paraquat input flow exists (Kongboon, 2013).
    INSERT INTO flow (flow_name, flow_type, unit_id)
    SELECT 'Paraquat dichloride (kg)', 'INPUT', v_kg_unit
    WHERE NOT EXISTS (
        SELECT 1
        FROM flow
        WHERE flow_name = 'Paraquat dichloride (kg)'
          AND flow_type = 'INPUT'
          AND unit_id = v_kg_unit
    );

    -- Reuse existing Diesel and Paraquat flows
    SELECT flow_id INTO v_diesel_flow
    FROM flow
    WHERE flow_name = 'Diesel'
      AND flow_type = 'INPUT'
      AND unit_id = v_l_unit
    LIMIT 1;

    SELECT flow_id INTO v_paraquat_flow
    FROM flow
    WHERE flow_name = 'Paraquat dichloride (kg)'
      AND flow_type = 'INPUT'
      AND unit_id = v_kg_unit
    LIMIT 1;

    IF v_diesel_flow IS NULL OR v_paraquat_flow IS NULL THEN
        RAISE EXCEPTION 'Existing Diesel or Paraquat flow is missing';
    END IF;

    -- Add generic inventory flows only when absent.
    -- These names do not imply a specific fertilizer formulation.
    FOR v_flow_name, v_amount IN
        SELECT * FROM (VALUES
            ('Nitrogen (nutrient)', 160.00::NUMERIC),
            ('Phosphorus (nutrient)', 125.63::NUMERIC),
            ('Potassium (nutrient)', 131.25::NUMERIC),
            ('Ametine', 7.00::NUMERIC)
        ) AS x(flow_name, amount)
    LOOP
        SELECT flow_id INTO v_flow_id
        FROM flow
        WHERE flow_name = v_flow_name
          AND flow_type = 'INPUT'
          AND unit_id = v_kg_unit
        LIMIT 1;

        IF v_flow_id IS NULL THEN
            INSERT INTO flow (flow_name, flow_type, unit_id)
            VALUES (v_flow_name, 'INPUT', v_kg_unit)
            RETURNING flow_id INTO v_flow_id;
        END IF;

        IF v_flow_name = 'Nitrogen (nutrient)' THEN
            v_n_flow := v_flow_id;
        ELSIF v_flow_name = 'Phosphorus (nutrient)' THEN
            v_p_flow := v_flow_id;
        ELSIF v_flow_name = 'Potassium (nutrient)' THEN
            v_k_flow := v_flow_id;
        ELSIF v_flow_name = 'Ametine' THEN
            v_ametine_flow := v_flow_id;
        END IF;
    END LOOP;

    -- Inventory exchanges
    FOR v_flow_id, v_exchange_type, v_amount, v_unit_id IN
        SELECT * FROM (VALUES
            (v_n_flow,       'INPUT'::TEXT, 160.00::NUMERIC, v_kg_unit),
            (v_p_flow,       'INPUT'::TEXT, 125.63::NUMERIC, v_kg_unit),
            (v_k_flow,       'INPUT'::TEXT, 131.25::NUMERIC, v_kg_unit),
            (v_paraquat_flow,'INPUT'::TEXT,   7.94::NUMERIC, v_kg_unit),
            (v_ametine_flow, 'INPUT'::TEXT,   7.00::NUMERIC, v_kg_unit),
            (v_diesel_flow,  'INPUT'::TEXT,  45.63::NUMERIC, v_l_unit)
        ) AS x(flow_id, exchange_type, amount, unit_id)
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM lci_exchange
            WHERE batch_process_id = v_batch_process_id
              AND flow_id = v_flow_id
              AND exchange_type = v_exchange_type
              AND amount = v_amount
              AND unit_id = v_unit_id
              AND source_id = v_source_id
              AND data_year = 2011
        ) THEN
            INSERT INTO lci_exchange (
                batch_process_id, flow_id, exchange_type,
                amount, unit_id, source_id, data_year
            )
            VALUES (
                v_batch_process_id, v_flow_id, v_exchange_type,
                v_amount, v_unit_id, v_source_id, 2011
            );
        END IF;
    END LOOP;

    -- Harvested cassava output
    SELECT flow_id INTO v_flow_id
    FROM flow
    WHERE product_id = v_product_id
      AND flow_type = 'OUTPUT'
      AND unit_id = v_kg_unit
    LIMIT 1;

    IF v_flow_id IS NULL THEN
        INSERT INTO flow (flow_name, flow_type, product_id, unit_id)
        VALUES ('Fresh cassava root', 'OUTPUT', v_product_id, v_kg_unit)
        RETURNING flow_id INTO v_flow_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM lci_exchange
        WHERE batch_process_id = v_batch_process_id
          AND flow_id = v_flow_id
          AND exchange_type = 'OUTPUT'
          AND amount = 22906.25
          AND unit_id = v_kg_unit
          AND source_id = v_source_id
          AND data_year = 2011
    ) THEN
        INSERT INTO lci_exchange (
            batch_process_id, flow_id, exchange_type,
            amount, unit_id, source_id, data_year
        )
        VALUES (
            v_batch_process_id, v_flow_id, 'OUTPUT',
            22906.25, v_kg_unit, v_source_id, 2011
        );
    END IF;
END $$;

COMMIT;
