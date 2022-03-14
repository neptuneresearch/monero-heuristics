-- Requires: tx_input_list_rct_count_tx_version (monero-sql/ringsql_count/txinput_rct_count)
CREATE VIEW tx_ringmember_sourcetx_count_tx_dist_version AS
    WITH tx_ringmember_sourcetx_count_tx__count_version AS (
        SELECT
            V0."version" AS "version",
            COUNT(S.*) AS n_tx_total
        FROM monero_version V
        JOIN monero_version V0 ON V0."version" = V."version" - 1
        JOIN tx_ringmember_sourcetx_count_tx S ON S.tx_block_height >= V0."height" AND S.tx_block_height < V."height"
        GROUP BY V0."version"
    )
    SELECT 
        V0."version" AS "version",
        TXCASE.tx_n_inputs,
        TXCASE.tx_ring_size,
        TXCASE.arr_n_inputs,
        TXCASE.arr_n_ringmembers,
        -- Number of transactions with above attributes
        COUNT(*) AS n_tx,
        -- Pct out of all cases in version
        ROUND((COUNT(*)::decimal / CASEVER.n_tx_total::decimal)*100.0, 3) AS n_tx_case_version_pct,
        -- Pct out of all RCT tx in version
        ROUND((COUNT(*)::decimal / RCTVER.n_tx::decimal)*100.0, 3) AS n_tx_allrct_version_pct
    FROM monero_version V
    JOIN monero_version V0 ON V0."version" = V."version" - 1
    JOIN tx_ringmember_sourcetx_count_tx TXCASE ON TXCASE.tx_block_height >= V0."height" AND TXCASE.tx_block_height < V."height"
    JOIN tx_ringmember_sourcetx_count_tx__count_version CASEVER ON CASEVER."version" = V0."version"
    JOIN tx_input_list_rct_count_tx_version RCTVER ON RCTVER."version" = V0."version"
    GROUP BY 
        V0."version",
        TXCASE.tx_n_inputs,
        TXCASE.tx_ring_size,
        TXCASE.arr_n_inputs,
        TXCASE.arr_n_ringmembers,
        CASEVER.n_tx_total,
        RCTVER.n_tx
    ORDER BY n_tx DESC;