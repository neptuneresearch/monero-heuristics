--   Row level: transactioninput-ringmembertransaction
CREATE MATERIALIZED VIEW tx_ringmember_sourcetx_count_sameinput AS (
    SELECT
        tx_block_height,
        tx_hash,
        tx_vin_index,
        ringmember_tx_hash,
        COUNT(1) AS n_ringmembers
    FROM tx_ringmember_list
    WHERE tx_vin_amount = 0 -- RingCT Only
    GROUP BY tx_block_height, tx_hash, tx_vin_index, ringmember_tx_hash
    HAVING COUNT(ringmember_tx_hash) > 1
) WITH NO DATA;

-- Runtime: 10m15s
REFRESH MATERIALIZED VIEW tx_ringmember_sourcetx_count_sameinput;