-- Confirm if there is any data and if it looks correct
SELECT *
FROM tx_input_ring_size_sametx_diffinput_diffringsize
ORDER BY height DESC
LIMIT 100;

-- How many occurrences?
-- 1. 2884303 transaction inputs
SELECT COUNT(1)
FROM tx_input_ring_size_sametx_diffinput_diffringsize;

-- 2. 2478 transactions
WITH distinct_tx AS ( 
	SELECT DISTINCT 
		height,
		tx_index
	FROM tx_input_ring_size_sametx_diffinput_diffringsize
)
SELECT
	COUNT(1)
FROM distinct_tx;