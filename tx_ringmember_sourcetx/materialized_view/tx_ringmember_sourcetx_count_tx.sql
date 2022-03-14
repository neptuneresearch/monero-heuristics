-- Transaction level roll-up of tx_ringmember_sourcetx_count.
-- Returns 1 row per transaction, with the metadata of each of its Transaction-Source Transaction pairs listed in array columns.
-- Requires:
-- - tx_attribute with INDEX tx_attribute_tx_hash
-- - tx_ring_stat with INDEX tx_ring_stat_tx_hash
CREATE MATERIALIZED VIEW tx_ringmember_sourcetx_count_tx AS (
    SELECT
        BASE.tx_block_height,
        BASE.tx_hash,
        TXATTR.tx_n_inputs,
        TXRS.ring_size AS tx_ring_size,
        -- ORDER BY: use matching ORDER BYs to guarantee same order between arrays
        ARRAY_AGG(BASE.n_inputs ORDER BY BASE.ringmember_tx_hash) AS arr_n_inputs,
        ARRAY_AGG(BASE.n_ringmembers ORDER BY BASE.ringmember_tx_hash) AS arr_n_ringmembers
    FROM tx_ringmember_sourcetx_count BASE
    JOIN tx_attribute TXATTR ON TXATTR.tx_hash = BASE.tx_hash
    JOIN tx_ring_stat TXRS ON TXRS.tx_hash = BASE.tx_hash
    GROUP BY BASE.tx_block_height, BASE.tx_hash, TXATTR.tx_n_inputs, TXRS.ring_size
    ORDER BY BASE.tx_block_height ASC
) WITH NO DATA;

-- Runtime @H=2576199: 2m15s
REFRESH MATERIALIZED VIEW tx_ringmember_sourcetx_count_tx;