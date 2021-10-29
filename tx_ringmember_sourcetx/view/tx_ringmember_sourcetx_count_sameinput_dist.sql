CREATE VIEW tx_ringmember_sourcetx_count_sameinput_dist AS
    WITH tx_ringmember_sourcetx_count_sameinput__count AS (
        -- Number of transaction inputs that have at least 2 ringmembers from the same source transaction
        SELECT COUNT(*) AS n_total_txinput
        FROM tx_ringmember_sourcetx_count_sameinput
    )
    SELECT 
        SI.n_ringmembers,
        -- Number of transactioninput-ringmembertransaction pairs, of n_ringmembers set size
        COUNT(*) AS n_txinput,
        -- Pct out of all SAMEINPUT transactioninput-ringmembertransaction pairs
        ROUND((COUNT(*)::decimal / SIN.n_total_txinput::decimal)*100.0, 3) AS n_txinput_pct,
        -- Pct out of all RCT tx inputs: SELECT COUNT(*) FROM tx_input_list_rct_count_ringmember = 34593457
        ROUND((COUNT(*)::decimal / 34593457::decimal)*100.0, 3) AS n_txinput_pct_rct
    FROM tx_ringmember_sourcetx_count_sameinput SI, 
        tx_ringmember_sourcetx_count_sameinput__count SIN
    GROUP BY SI.n_ringmembers, SIN.n_total_txinput
    ORDER BY SI.n_ringmembers ASC;