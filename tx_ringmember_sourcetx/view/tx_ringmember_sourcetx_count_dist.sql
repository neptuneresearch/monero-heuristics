CREATE VIEW tx_ringmember_sourcetx_count_dist AS
    WITH tx_ringmember_sourcetx_count__count AS (
        -- Number of transactions that have at least 2 ringmembers from the same source transaction
        SELECT COUNT(*) AS n_total_tx
        FROM tx_ringmember_sourcetx_count
    )
    SELECT 
        AI.n_ringmembers,
        -- Number of transactions, of n_ringmembers set size
        COUNT(*) AS n_tx,
        -- Pct out of all ANYINPUT transactions
        ROUND((COUNT(*)::decimal / AIN.n_total_tx::decimal)*100.0, 3) AS n_tx_pct,
        -- Pct out of all RCT tx: SELECT COUNT(*) FROM tx_input_list_rct_count_tx = 15647807
        ROUND((COUNT(*)::decimal / 15647807::decimal)*100.0, 3) AS n_tx_pct_rct
    FROM tx_ringmember_sourcetx_count AI, 
        tx_ringmember_sourcetx_count__count AIN
    GROUP BY AI.n_ringmembers, AIN.n_total_tx
    ORDER BY AI.n_ringmembers ASC;