CREATE MATERIALIZED VIEW tx_input_ring_size AS
    -- Helper view for tx_input_ring_size_sametx_diffinput_diffringsize
    SELECT 
        height,
        tx_index,
        vin_index,
        COUNT(vin_key_offset_index) AS ring_size
    FROM tx_input_list 
    GROUP BY height, tx_index, vin_index
    ORDER BY height ASC, tx_index ASC, vin_index ASC
WITH NO DATA;

-- Runtime 4m15s
REFRESH MATERIALIZED VIEW tx_input_ring_size;