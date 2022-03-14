-- Requires: tx_input_list_rct_count_tx (monero-sql/ringsql_count/txinput_rct_count)
CREATE VIEW tx_ringmember_sourcetx_count_tx_dist AS
    WITH tx_ringmember_sourcetx_count_tx__count AS (
        SELECT COUNT(*) AS n_tx_total
        FROM tx_ringmember_sourcetx_count_tx
    )
    SELECT 
        TXCASE.tx_n_inputs,
        TXCASE.tx_ring_size,
        TXCASE.arr_n_inputs,
        TXCASE.arr_n_ringmembers,
        -- Number of transactions with above attributes
        COUNT(*) AS n_tx,
        -- Pct out of all cases
        ROUND((COUNT(*)::decimal / tx_ringmember_sourcetx_count_tx__count.n_tx_total::decimal)*100.0, 3) AS pct_tx_case,
        -- Pct out of all RCT tx
        ROUND((COUNT(*)::decimal / tx_input_list_rct_count_tx.n_tx::decimal)*100.0, 3) AS pct_tx_allrct
    FROM tx_ringmember_sourcetx_count_tx TXCASE,
        tx_ringmember_sourcetx_count_tx__count,
        tx_input_list_rct_count_tx
    GROUP BY 
        TXCASE.tx_n_inputs,
        TXCASE.tx_ring_size,
        TXCASE.arr_n_inputs,
        TXCASE.arr_n_ringmembers,
        tx_ringmember_sourcetx_count_tx__count.n_tx_total,
        tx_input_list_rct_count_tx.n_tx
    ORDER BY n_tx DESC;