CREATE VIEW tx_ringmember_sourcetx_count_sameinput_multiple_dist AS
    WITH tx_ringmember_sourcetx_count_sameinput_multiple__count AS (
        -- Number of transactions that re-used multiple source transactions for multiple ringmembers respectively,
        -- within the same transaction input
        SELECT COUNT(*) AS n_total_tx
        FROM tx_ringmember_sourcetx_count_sameinput_multiple
    )
    SELECT 
        SIM.n_ringmember_sourcetx,
        -- Number of transactions, of n_ringmember_sourcetx set size
        COUNT(*) AS n_tx,
        -- Pct out of all SAMEINPUT MULTIPLE transactions
        ROUND((COUNT(*)::decimal / SIMN.n_total_tx::decimal)*100.0, 3) AS n_tx_pct,
        -- Pct out of all RCT tx: SELECT COUNT(*) FROM tx_input_list_rct_count_tx = 15647807
        ROUND((COUNT(*)::decimal / 15647807::decimal)*100.0, 3) AS n_tx_pct_rct
    FROM tx_ringmember_sourcetx_count_sameinput_multiple SIM, 
        tx_ringmember_sourcetx_count_sameinput_multiple__count SIMN
    GROUP BY SIM.n_ringmember_sourcetx, SIMN.n_total_tx
    ORDER BY SIM.n_ringmember_sourcetx ASC;