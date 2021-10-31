CREATE MATERIALIZED VIEW tx_input_ring_size_sametx_diffinput_diffringsize AS
    -- Question: If a transaction has multiple inputs, do they all have the same ring size?
    SELECT
        A.height,
        A.tx_index,
        A.vin_index AS vin_index_A,
        B.vin_index AS vin_index_B,
        A.ring_size AS ring_size_A,
        B.ring_size AS ring_size_B
    -- From the list of ring sizes of [all tx inputs of all tx of all blocks]
    FROM tx_input_ring_size A
    -- find another input which is:
    JOIN tx_input_ring_size B
        -- Same transaction
        ON A.height = B.height
        AND A.tx_index = B.tx_index
        -- Different input
        --   NOT EQUAL "<>" establishes difference but returns twice: (A,B) and (B,A).
        --   LESS THAN "<" also gives difference and only returns once: (A,B).
        AND A.vin_index < B.vin_index
        -- Different ring size
        AND A.ring_size <> B.ring_size
WITH NO DATA;

-- Runtime 5m27s
REFRESH MATERIALIZED VIEW tx_input_ring_size_sametx_diffinput_diffringsize;