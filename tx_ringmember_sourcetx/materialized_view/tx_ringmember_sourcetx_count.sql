-- RingCT transactions that re-use some source transaction for multiple ringmembers.
-- Returns 1 row per Transaction-Source Transaction pair.
-- Inputs are not distinguished, so this will include re-usage both across different and in same inputs.
--   n_inputs: = 1 means "same input", > 1 means "different inputs".
CREATE MATERIALIZED VIEW tx_ringmember_sourcetx_count AS (
    SELECT
        tx_block_height,
        tx_hash,
        ringmember_tx_hash,
        COUNT(DISTINCT tx_vin_index) AS n_inputs,
        COUNT(*) AS n_ringmembers
    FROM tx_ringmember_list
    -- tx_vin_amount=0: RingCT filter
    WHERE tx_vin_amount = 0
    GROUP BY tx_block_height, tx_hash, ringmember_tx_hash
    HAVING COUNT(ringmember_tx_hash) > 1
) WITH NO DATA;

-- Runtime H=2576199: 17m3s
REFRESH MATERIALIZED VIEW tx_ringmember_sourcetx_count;