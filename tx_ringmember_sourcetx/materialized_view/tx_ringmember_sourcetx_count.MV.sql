-- Row level: transaction
--   RingCT transactions that re-use some source transaction for multiple ringmembers
--   Note: this will include 'sameinput' counts
CREATE MATERIALIZED VIEW tx_ringmember_sourcetx_count AS (
    SELECT
        tx_block_height,
        tx_hash,
        ringmember_tx_hash,
        COUNT(1) AS n_ringmembers
    FROM tx_ringmember_list
    WHERE tx_vin_amount = 0 -- RingCT Only
    GROUP BY tx_block_height, tx_hash, ringmember_tx_hash
    HAVING COUNT(ringmember_tx_hash) > 1
) WITH NO DATA;

-- Runtime: 9m
REFRESH MATERIALIZED VIEW tx_ringmember_sourcetx_count;