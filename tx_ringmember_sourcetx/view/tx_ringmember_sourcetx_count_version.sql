CREATE VIEW tx_ringmember_sourcetx_count_version AS
    SELECT
        V0."version" AS "version",
        V0."height" AS "height",
        AI.n_ringmembers AS n_ringmembers,
        COUNT(AI.*) AS n_tx,
        ROUND((COUNT(AI.*)::decimal / VNTX.n_tx::decimal)*100.0, 3) AS n_tx_pct_rct_version
    FROM monero_version V
    JOIN monero_version V0 ON V0."version" = V."version" - 1
    JOIN tx_ringmember_sourcetx_count AI ON AI.tx_block_height >= V0."height" AND AI.tx_block_height < V."height"
    JOIN tx_input_list_rct_count_tx_version VNTX ON VNTX."version" = V0."version"
    GROUP BY V0."version", V0."height", AI.n_ringmembers, VNTX.n_tx
    ORDER BY V0."height", V0."height", AI.n_ringmembers, VNTX.n_tx;