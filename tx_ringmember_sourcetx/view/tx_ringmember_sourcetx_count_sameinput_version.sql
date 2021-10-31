CREATE VIEW tx_ringmember_sourcetx_count_sameinput_version AS
    SELECT
        V0."version" AS "version",
        V0."height" AS "height",
        SI.n_ringmembers AS n_ringmembers,
        COUNT(SI.*) AS n_txinputs,
        ROUND((COUNT(SI.*)::decimal / VNTXI.n_txinputs::decimal)*100.0, 3) AS n_txinputs_pct_rct_version
    FROM monero_version V
    JOIN monero_version V0 ON V0."version" = V."version" - 1
    JOIN tx_ringmember_sourcetx_count_sameinput SI ON SI.tx_block_height >= V0."height" AND SI.tx_block_height < V."height"
    JOIN tx_input_list_rct_count_ringmember_version VNTXI ON VNTXI."version" = V0."version"
    GROUP BY V0."version", V0."height", SI.n_ringmembers, VNTXI.n_txinputs
    ORDER BY V0."height", V0."height", SI.n_ringmembers, VNTXI.n_txinputs;