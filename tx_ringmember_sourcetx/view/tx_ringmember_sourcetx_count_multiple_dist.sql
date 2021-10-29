CREATE VIEW tx_ringmember_sourcetx_count_multiple_dist AS
    WITH tx_ringmember_sourcetx_count_multiple__count AS (
        -- Number of transactions that re-used multiple source transactions for multiple ringmembers respectively,
        -- within the same, or across different, transaction inputs
        SELECT COUNT(*) AS n_total_tx
        FROM tx_ringmember_sourcetx_count_multiple
    )
    SELECT 
        AIM.n_ringmember_sourcetx,
        -- Number of transactions, of n_ringmember_sourcetx set size
        COUNT(*) AS n_tx,
        -- Pct out of all ANYINPUT MULTIPLE transactions
        ROUND((COUNT(*)::decimal / AIMN.n_total_tx::decimal)*100.0, 3) AS n_tx_pct,
        -- Pct out of all RCT tx: SELECT COUNT(*) FROM tx_input_list_rct_count_tx = 15647807
        ROUND((COUNT(*)::decimal / 15647807::decimal)*100.0, 3) AS n_tx_pct_rct
    FROM tx_ringmember_sourcetx_count_multiple AIM, 
        tx_ringmember_sourcetx_count_multiple__count AIMN
    GROUP BY AIM.n_ringmember_sourcetx, AIMN.n_total_tx
    ORDER BY AIM.n_ringmember_sourcetx ASC;