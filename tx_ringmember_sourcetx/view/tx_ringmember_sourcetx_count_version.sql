CREATE VIEW tx_ringmember_sourcetx_count_version AS
    SELECT
        V0."version" AS "version",
        V0."height" AS "height",
        AI.n_ringmembers AS n_ringmembers,
        COUNT(AI.*) AS n_tx
    FROM monero_version V
    JOIN monero_version V0 ON V0."version" = V."version" - 1
    JOIN tx_ringmember_sourcetx_count AI ON AI.tx_block_height >= V0."height" AND AI.tx_block_height < V."height"
    GROUP BY V0."version", V0."height", AI.n_ringmembers
    ORDER BY V0."height", V0."height", AI.n_ringmembers;