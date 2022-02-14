CREATE MATERIALIZED VIEW tx_input_ring_size_sametx_diffinput_diffringsize AS
    -- Question: If a transaction has multiple inputs, do they all have the same ring size?
    SELECT
        A.block_height,
        A.tx_index,
        A.tx_hash,
        A.vin_index AS vin_index_A,
        B.vin_index AS vin_index_B,
        A.ring_size AS ring_size_A,
        B.ring_size AS ring_size_B
    -- From the list of ring sizes of [all tx inputs of all tx of all blocks]
    FROM tx_input_ring_stat A
    -- find another input which is:
    JOIN tx_input_ring_stat B
        -- Same transaction
        ON A.block_height = B.block_height
        AND A.tx_index = B.tx_index
        -- Different ring size; put the greater size into B
        --   This also implicitly guarantees A.vin_index <> B.vin_index, because never can have a ring_size less than itself
        AND A.ring_size < B.ring_size
WITH NO DATA;

-- Runtime: 5m27s
REFRESH MATERIALIZED VIEW tx_input_ring_size_sametx_diffinput_diffringsize;