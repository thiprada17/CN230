SET search_path TO core, catalog, process, production, lci, impact, public;
BEGIN;

DO $$
DECLARE
    v_source_id INTEGER := 3;
    v_product_id INTEGER := 2;
    v_unit_id INTEGER := 1;
    v_location_id INTEGER;
    v_process_id INTEGER;
    v_step_id INTEGER;
    v_batch_id INTEGER;
    v_batch_process_id INTEGER;
    v_input_flow_id INTEGER;
    v_whole_flow_id INTEGER;
    v_broken_flow_id INTEGER;
    v_withered_flow_id INTEGER;
BEGIN
    -- Experimental location is not specified in the article.
    -- Thailand is the study context; province and district remain explicitly unspecified.
    SELECT location_id INTO v_location_id
    FROM location
    WHERE country = 'Thailand'
      AND province = 'Not specified'
      AND district = 'Not specified'
    LIMIT 1;

    IF v_location_id IS NULL THEN
        INSERT INTO location (province, district, country)
        VALUES ('Not specified', 'Not specified', 'Thailand')
        RETURNING location_id INTO v_location_id;
    END IF;

    -- Separate process: do not combine with the UNIDO 1980 reference.
    SELECT process_id INTO v_process_id
    FROM process
    WHERE process_name =
        'Hom Mali rice milling - small machine trial (Khomkaew 2022)'
    LIMIT 1;

    IF v_process_id IS NULL THEN
        INSERT INTO process (process_name, description)
        VALUES (
            'Hom Mali rice milling - small machine trial (Khomkaew 2022)',
            'Separate small milling-machine trial reported by Khomkaew (2022). Paddy moisture content: 12.1%. Each trial used 10 kg paddy. Reported milling time: 6.2 minutes; flow rate: 1.36 kg/min. The article does not specify the experimental location or calendar year of the trial.'
        )
        RETURNING process_id INTO v_process_id;
    END IF;

    SELECT step_id INTO v_step_id
    FROM process_step
    WHERE process_id = v_process_id
      AND step_name = 'Small-machine milling at 12.1% paddy moisture'
    LIMIT 1;

    IF v_step_id IS NULL THEN
        INSERT INTO process_step
            (process_id, step_name, step_order, description)
        VALUES (
            v_process_id,
            'Small-machine milling at 12.1% paddy moisture',
            1,
            '10 kg paddy per trial; reported milling time 6.2 minutes and flow rate 1.36 kg/min. Reported outputs: 5.60 kg whole kernel rice, 0.93 kg broken rice and 2.92 kg withered rice. The reported outputs total 9.45 kg; 0.55 kg is unaccounted for in the reported figures and is not assigned to an invented flow.'
        )
        RETURNING step_id INTO v_step_id;
    END IF;

    -- Reuse the existing whole-rice product as the main batch product.
    SELECT pb.batch_id INTO v_batch_id
    FROM production_batch pb
    JOIN batch_process bp ON bp.batch_id = pb.batch_id
    WHERE pb.product_id = v_product_id
      AND pb.production_quantity = 5.60
      AND pb.unit_id = v_unit_id
      AND bp.step_id = v_step_id
    LIMIT 1;

    IF v_batch_id IS NULL THEN
        INSERT INTO production_batch
            (product_id, production_quantity, unit_id, location_id,
             production_date, production_year, area_ha)
        VALUES
            (v_product_id, 5.60, v_unit_id, v_location_id,
             NULL, NULL, NULL)
        RETURNING batch_id INTO v_batch_id;
    END IF;

    SELECT batch_process_id INTO v_batch_process_id
    FROM batch_process
    WHERE batch_id = v_batch_id
      AND step_id = v_step_id
    LIMIT 1;

    IF v_batch_process_id IS NULL THEN
        INSERT INTO batch_process
            (batch_id, step_id, execution_order, location_id)
        VALUES
            (v_batch_id, v_step_id, 1, v_location_id)
        RETURNING batch_process_id INTO v_batch_process_id;
    END IF;

    -- Dedicated generic input flow; do not reuse the UNIDO paddy flow.
    SELECT flow_id INTO v_input_flow_id
    FROM flow
    WHERE flow_name = 'Hom Mali paddy rice (12.1% moisture) - Khomkaew 2022'
      AND product_id IS NULL
      AND material_id IS NULL
    LIMIT 1;

    IF v_input_flow_id IS NULL THEN
        INSERT INTO flow (flow_name, flow_type, unit_id)
        VALUES (
            'Hom Mali paddy rice (12.1% moisture) - Khomkaew 2022',
            'INPUT',
            v_unit_id
        )
        RETURNING flow_id INTO v_input_flow_id;
    END IF;

    SELECT flow_id INTO v_whole_flow_id
    FROM flow
    WHERE product_id = 2 AND flow_type = 'OUTPUT'
    LIMIT 1;

    SELECT flow_id INTO v_broken_flow_id
    FROM flow
    WHERE product_id = 3 AND flow_type = 'OUTPUT'
    LIMIT 1;

    SELECT flow_id INTO v_withered_flow_id
    FROM flow
    WHERE product_id = 4 AND flow_type = 'OUTPUT'
    LIMIT 1;

    IF v_whole_flow_id IS NULL
       OR v_broken_flow_id IS NULL
       OR v_withered_flow_id IS NULL THEN
        RAISE EXCEPTION 'Required existing rice output flows are missing.';
    END IF;

    -- 2022 is the publication-year proxy because the experimental year is not reported.
    IF NOT EXISTS (
        SELECT 1 FROM lci_exchange
        WHERE batch_process_id = v_batch_process_id
          AND flow_id = v_input_flow_id
          AND exchange_type = 'INPUT'
          AND amount = 10
          AND source_id = v_source_id
    ) THEN
        INSERT INTO lci_exchange
            (batch_process_id, flow_id, exchange_type, amount,
             unit_id, source_id, data_year)
        VALUES
            (v_batch_process_id, v_input_flow_id, 'INPUT', 10,
             v_unit_id, v_source_id, 2022);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM lci_exchange
        WHERE batch_process_id = v_batch_process_id
          AND flow_id = v_whole_flow_id
          AND exchange_type = 'OUTPUT'
          AND amount = 5.60
          AND source_id = v_source_id
    ) THEN
        INSERT INTO lci_exchange
            (batch_process_id, flow_id, exchange_type, amount,
             unit_id, source_id, data_year)
        VALUES
            (v_batch_process_id, v_whole_flow_id, 'OUTPUT', 5.60,
             v_unit_id, v_source_id, 2022);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM lci_exchange
        WHERE batch_process_id = v_batch_process_id
          AND flow_id = v_broken_flow_id
          AND exchange_type = 'OUTPUT'
          AND amount = 0.93
          AND source_id = v_source_id
    ) THEN
        INSERT INTO lci_exchange
            (batch_process_id, flow_id, exchange_type, amount,
             unit_id, source_id, data_year)
        VALUES
            (v_batch_process_id, v_broken_flow_id, 'OUTPUT', 0.93,
             v_unit_id, v_source_id, 2022);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM lci_exchange
        WHERE batch_process_id = v_batch_process_id
          AND flow_id = v_withered_flow_id
          AND exchange_type = 'OUTPUT'
          AND amount = 2.92
          AND source_id = v_source_id
    ) THEN
        INSERT INTO lci_exchange
            (batch_process_id, flow_id, exchange_type, amount,
             unit_id, source_id, data_year)
        VALUES
            (v_batch_process_id, v_withered_flow_id, 'OUTPUT', 2.92,
             v_unit_id, v_source_id, 2022);
    END IF;
END $$;

COMMIT;

