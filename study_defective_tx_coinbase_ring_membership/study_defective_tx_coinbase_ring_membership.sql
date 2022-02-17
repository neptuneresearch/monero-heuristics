CREATE OR REPLACE PROCEDURE study_defective_tx_coinbase_ring_membership(
    read_enabled BOOLEAN DEFAULT TRUE,
    write_enabled BOOLEAN DEFAULT TRUE,
    index_enabled BOOLEAN DEFAULT TRUE,
    print_timing_enabled BOOLEAN DEFAULT TRUE,
    section_size DECIMAL DEFAULT 10
) LANGUAGE plpgsql AS $$ 
DECLARE
    block_height_start INTEGER;
    block_height_end INTEGER;
    total_len DECIMAL;
    s1_size DECIMAL;
    n_sections DECIMAL;
    section_check_even DECIMAL;
    section_index INTEGER;
    section_block_height_start INTEGER;
    section_block_height_end INTEGER;
    n_ringmembers INTEGER;
    n_coinbase_ringmembers INTEGER;
    e_tx_n_outputs INTEGER;
    e_coinbase_tx_n_outputs INTEGER;
BEGIN
    /*
        USAGE

            Defective Transactions
                Search this file for table alias TX_SET_SUBJECT and change the target table.
                This table must include columns { block_height, tx_hash }.

            read_enabled
                Enable to read TX_SET_SUBJECT into study_defective_tx_coinbase_ring_membership__data.
                Must be enabled on first run.
                Can be disabled on subsequent runs to save time.

            write_enabled
                Enable to save results to table study_defective_tx_coinbase_ring_membership__output.
                Can disable to save time while debugging.

            index_enabled
                Enable to index study_defective_tx_coinbase_ring_membership__data.

            print_timing_enabled
                Enable to print the timestamp of queries A-D in the analysis phase.

            section_size
                Adjust as desired.
    */

    IF write_enabled THEN
        RAISE NOTICE 'study [%]: Creating output table', timeofday()::timestamp;

        DROP TABLE IF EXISTS study_defective_tx_coinbase_ring_membership__output;
        
        CREATE TABLE study_defective_tx_coinbase_ring_membership__output (
            section_index INTEGER,
            section_block_height_start INTEGER,
            section_block_height_end INTEGER,
            n_ringmembers INTEGER,
            n_coinbase_ringmembers INTEGER,
            e_tx_n_outputs INTEGER,
            e_coinbase_tx_n_outputs INTEGER
        );
    END IF;

    -- (1)(b) Get ringmembers
    IF read_enabled THEN
        RAISE NOTICE 'study [%]: Creating ringmember dataset from tx list', timeofday()::timestamp;

        -- Side-effect: indices will also be dropped if they exist
        DROP MATERIALIZED VIEW IF EXISTS study_defective_tx_coinbase_ring_membership__data;

        CREATE MATERIALIZED VIEW study_defective_tx_coinbase_ring_membership__data AS (
            WITH subject_subset AS (
                SELECT tx_hash
                FROM tx_fee_round_list_2508299 TX_SET_SUBJECT
                ORDER BY block_height DESC
                LIMIT 100
            )
            SELECT
                R.tx_block_height,
                R.tx_block_timestamp,
                R.tx_block_tx_index,
                R.tx_hash,
                R.tx_vin_index,
                R.tx_vin_amount,
                R.tx_vin_ringmember_index,
                R.ringmember_block_height,
                R.ringmember_block_timestamp,
                R.ringmember_block_tx_index,
                R.ringmember_tx_hash,
                R.ringmember_tx_txo_index,
                R.ringmember_txo_amount_index
            FROM tx_ringmember_list R
            JOIN subject_subset S ON S.tx_hash = R.tx_hash
        );

        IF index_enabled THEN
            CREATE INDEX study_defective_tx_c_r_m__data_ringmember_block_height
                ON study_defective_tx_coinbase_ring_membership__data (ringmember_block_height);

            CREATE INDEX study_defective_tx_c_r_m__data_ringmember_block_height_coinbase
                ON study_defective_tx_coinbase_ring_membership__data (ringmember_block_height)
                WHERE ringmember_block_tx_index = -1;
        END IF;

        COMMIT;
    ELSE
        IF NOT EXISTS (SELECT 1 FROM study_defective_tx_coinbase_ring_membership__data LIMIT 1) THEN
            RAISE NOTICE 'study [%]: No data! Run again with read_enabled.', timeofday()::timestamp;
            RETURN;
        END IF;
    END IF;

    -- (2)(a) Height A = oldest ringmember
    RAISE NOTICE 'study [%]: Calculating block range', timeofday()::timestamp;

    -- Uses index study_defective_tx_c_r_m__data_ringmember_block_height
    SELECT ringmember_block_height
    INTO block_height_start
    FROM study_defective_tx_coinbase_ring_membership__data
    ORDER BY ringmember_block_height ASC
    LIMIT 1;

    -- (2)(b) Height B = youngest ringmember
    -- Uses index study_defective_tx_c_r_m__data_ringmember_block_height
    SELECT ringmember_block_height
    INTO block_height_end
    FROM study_defective_tx_coinbase_ring_membership__data
    ORDER BY ringmember_block_height DESC
    LIMIT 1;

    -- (3) Divide A to B range into equal sections (or Section 1 may be larger to make rest equal)
    s1_size = section_size;
    
    -- total_len: Adds 1 to include the first block
    total_len = (block_height_end - block_height_start) + 1;
        
    -- n_sections: Adds 1 to add the first section back to the count
    n_sections = ((total_len - s1_size) / section_size) + 1;
    
    section_check_even = ((total_len - s1_size) % section_size);
    IF section_check_even > 0 THEN
        s1_size = s1_size + section_check_even;
        n_sections = ((total_len - s1_size) / section_size) + 1;
    END IF;
    
    RAISE NOTICE 'study [%]: block_height_start=% block_height_end=% total_len=% n_sections=% s1_size=%', timeofday()::timestamp, 
                             block_height_start,  block_height_end,  total_len,  n_sections,  s1_size;

    -- (4) Analysis
    FOR section_index IN 1 .. n_sections LOOP
        section_block_height_start = block_height_start
            -- Add section 1
            + CASE WHEN section_index > 1 THEN s1_size ELSE 0 END 
            -- Add the preceding sections
            + CASE WHEN section_index > 2 THEN section_size * (section_index - 2) ELSE 0 END;
        
        section_block_height_end = section_block_height_start 
            + CASE WHEN section_index = 1 THEN s1_size ELSE section_size END
            -- Go back one block because section_block_height_start already counted the first block
            - 1;

        -- a) the total number of ring members that we recorded in 1. 
        --   that origin from a block in S_i
        -- Uses index study_defective_tx_c_r_m__data_ringmember_block_height
        IF print_timing_enabled THEN
            RAISE NOTICE 'study [%]: #% [block % - %] finding n_r', timeofday()::timestamp, section_index, section_block_height_start, section_block_height_end;
        END IF;

        SELECT COUNT(*)
        INTO n_ringmembers
        FROM study_defective_tx_coinbase_ring_membership__data
        WHERE ringmember_block_height >= section_block_height_start
            AND ringmember_block_height <= section_block_height_end;

        -- b) the number of ring members we recorded in 1. 
        --   that are coinbase outputs and origin from a block in S_i
        -- Uses index study_defective_tx_c_r_m__data_ringmember_block_height_coinbase
        IF print_timing_enabled THEN
            RAISE NOTICE 'study [%]: #% [block % - %] finding n_cr', timeofday()::timestamp, section_index, section_block_height_start, section_block_height_end;
        END IF;

        SELECT COUNT(*)
        INTO n_coinbase_ringmembers
        FROM study_defective_tx_coinbase_ring_membership__data
        WHERE (ringmember_block_height >= section_block_height_start
            AND ringmember_block_height <= section_block_height_end)
            AND ringmember_block_tx_index = -1;

        -- c) the total number of outputs of transactions that appear in S_i
        -- Suggested indices:
        --   - tx_attribute.tx_hash
        --   - TX_SET_SUBJECT: tx_fee_round_list_2508299.tx_hash
        IF print_timing_enabled THEN
            RAISE NOTICE 'study [%]: #% [block % - %] finding e', timeofday()::timestamp, section_index, section_block_height_start, section_block_height_end;
        END IF;

        SELECT SUM(A.tx_n_outputs)
        INTO e_tx_n_outputs
        FROM tx_attribute A
        JOIN tx_fee_round_list_2508299 TX_SET_SUBJECT ON TX_SET_SUBJECT.tx_hash = A.tx_hash
        WHERE TX_SET_SUBJECT.block_height >= section_block_height_start
            AND TX_SET_SUBJECT.block_height <= section_block_height_end;

        -- d) the total number of coinbase outputs of transactions that appear in S_i
        -- Suggested index: coinbase_tx_attribute.block_height
        IF print_timing_enabled THEN
            RAISE NOTICE 'study [%]: #% [block % - %] finding e_c', timeofday()::timestamp, section_index, section_block_height_start, section_block_height_end;
        END IF;

        SELECT SUM(CA.tx_n_outputs)
        INTO e_coinbase_tx_n_outputs
        FROM coinbase_tx_attribute CA
        WHERE CA.block_height >= section_block_height_start
            AND CA.block_height <= section_block_height_end;

        IF write_enabled THEN
            INSERT INTO study_defective_tx_coinbase_ring_membership__output
            (
                section_index,
                section_block_height_start,
                section_block_height_end,
                n_ringmembers,
                n_coinbase_ringmembers,
                e_tx_n_outputs,
                e_coinbase_tx_n_outputs
            )
            VALUES
            (
                section_index,
                section_block_height_start,
                section_block_height_end,
                n_ringmembers,
                n_coinbase_ringmembers,
                e_tx_n_outputs,
                e_coinbase_tx_n_outputs
            );
        END IF;

        RAISE NOTICE 'study [%]: #% [block % - %] n_r=% n_cr=% e=% e_c=%', timeofday()::timestamp, section_index, section_block_height_start, section_block_height_end, n_ringmembers, n_coinbase_ringmembers, e_tx_n_outputs, e_coinbase_tx_n_outputs;
    END LOOP;

    RAISE NOTICE 'study [%]: OK', timeofday()::timestamp;
END;
$$;