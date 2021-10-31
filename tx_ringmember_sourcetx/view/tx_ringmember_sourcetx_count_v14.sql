CREATE VIEW tx_ringmember_sourcetx_count_dist_v14 AS
    WITH tx_ringmember_sourcetx_count__count AS (
        -- Number of transactions that have at least 2 ringmembers from the same source transaction
        SELECT COUNT(*) AS n_total_tx
        FROM tx_ringmember_sourcetx_count
        WHERE tx_block_height >= 2210720 --v14 Only
    )
    SELECT 
        AI.n_ringmembers,
        -- Number of transactions, of n_ringmembers set size
        COUNT(*) AS n_tx,
        -- Pct out of all ANYINPUT transactions
        ROUND((COUNT(*)::decimal / AIN.n_total_tx::decimal)*100.0, 3) AS n_tx_pct,
        -- Pct out of all RCT tx: tx_input_list_rct_count_tx_version[14] = 7273313
        ROUND((COUNT(*)::decimal / 7273313::decimal)*100.0, 3) AS n_tx_pct_rct
    FROM tx_ringmember_sourcetx_count AI, 
        tx_ringmember_sourcetx_count__count AIN
    WHERE AI.tx_block_height >= 2210720 --v14 Only
    GROUP BY AI.n_ringmembers, AIN.n_total_tx
    ORDER BY AI.n_ringmembers ASC;

CREATE VIEW tx_ringmember_sourcetx_count_multiple_dist_v14 AS
    WITH tx_ringmember_sourcetx_count_multiple__count AS (
        -- Number of transactions that re-used multiple source transactions for multiple ringmembers respectively,
        -- within the same, or across different, transaction inputs
        SELECT COUNT(*) AS n_total_tx
        FROM tx_ringmember_sourcetx_count_multiple
        WHERE tx_block_height >= 2210720 --v14 Only
    )
    SELECT 
        AIM.n_ringmember_sourcetx,
        -- Number of transactions, of n_ringmember_sourcetx set size
        COUNT(*) AS n_tx,
        -- Pct out of all ANYINPUT MULTIPLE transactions
        ROUND((COUNT(*)::decimal / AIMN.n_total_tx::decimal)*100.0, 3) AS n_tx_pct,
        -- Pct out of all RCT tx: tx_input_list_rct_count_tx_version[14] = 7273313
        ROUND((COUNT(*)::decimal / 7273313::decimal)*100.0, 3) AS n_tx_pct_rct
    FROM tx_ringmember_sourcetx_count_multiple AIM, 
        tx_ringmember_sourcetx_count_multiple__count AIMN
    WHERE AIM.tx_block_height >= 2210720 --v14 Only
    GROUP BY AIM.n_ringmember_sourcetx, AIMN.n_total_tx
    ORDER BY AIM.n_ringmember_sourcetx ASC;

CREATE VIEW tx_ringmember_sourcetx_count_sameinput_dist_v14 AS
    WITH tx_ringmember_sourcetx_count_sameinput__count AS (
        -- Number of transaction inputs that have at least 2 ringmembers from the same source transaction
        SELECT COUNT(*) AS n_total_txinput
        FROM tx_ringmember_sourcetx_count_sameinput
        WHERE tx_block_height >= 2210720 --v14 Only
    )
    SELECT 
        SI.n_ringmembers,
        -- Number of transactioninput-ringmembertransaction pairs, of n_ringmembers set size
        COUNT(*) AS n_txinput,
        -- Pct out of all SAMEINPUT transactioninput-ringmembertransaction pairs
        ROUND((COUNT(*)::decimal / SIN.n_total_txinput::decimal)*100.0, 3) AS n_txinput_pct,
        -- Pct out of all RCT tx inputs: tx_input_list_rct_count_ringmember_version[14] = 15504458
        ROUND((COUNT(*)::decimal / 15504458::decimal)*100.0, 3) AS n_txinput_pct_rct
    FROM tx_ringmember_sourcetx_count_sameinput SI, 
        tx_ringmember_sourcetx_count_sameinput__count SIN
    WHERE SI.tx_block_height >= 2210720 --v14 Only
    GROUP BY SI.n_ringmembers, SIN.n_total_txinput
    ORDER BY SI.n_ringmembers ASC;

CREATE VIEW tx_ringmember_sourcetx_count_sameinput_multiple_dist_v14 AS
    WITH tx_ringmember_sourcetx_count_sameinput_multiple__count AS (
        -- Number of transactions that re-used multiple source transactions for multiple ringmembers respectively,
        -- within the same transaction input
        SELECT COUNT(*) AS n_total_tx
        FROM tx_ringmember_sourcetx_count_sameinput_multiple
        WHERE tx_block_height >= 2210720 --v14 Only
    )
    SELECT 
        SIM.n_ringmember_sourcetx,
        -- Number of transactions, of n_ringmember_sourcetx set size
        COUNT(*) AS n_tx,
        -- Pct out of all SAMEINPUT MULTIPLE transactions
        ROUND((COUNT(*)::decimal / SIMN.n_total_tx::decimal)*100.0, 3) AS n_tx_pct,
        -- Pct out of all RCT tx: tx_input_list_rct_count_tx_version[14] = 7273313
        ROUND((COUNT(*)::decimal / 7273313::decimal)*100.0, 3) AS n_tx_pct_rct
    FROM tx_ringmember_sourcetx_count_sameinput_multiple SIM, 
        tx_ringmember_sourcetx_count_sameinput_multiple__count SIMN
    WHERE SIM.tx_block_height >= 2210720 --v14 Only
    GROUP BY SIM.n_ringmember_sourcetx, SIMN.n_total_tx
    ORDER BY SIM.n_ringmember_sourcetx ASC;