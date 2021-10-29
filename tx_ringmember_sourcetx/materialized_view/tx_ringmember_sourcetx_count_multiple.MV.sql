-- Row level: transaction
CREATE MATERIALIZED VIEW tx_ringmember_sourcetx_count_multiple AS (
    SELECT
        tx_block_height,
        tx_hash,
        COUNT(1) AS n_ringmember_sourcetx
    FROM tx_ringmember_sourcetx_count
    GROUP BY tx_block_height, tx_hash
    HAVING COUNT(tx_hash) > 1
) WITH NO DATA;

-- Runtime: 1s
REFRESH MATERIALIZED VIEW tx_ringmember_sourcetx_count_multiple;