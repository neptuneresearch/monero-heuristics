CREATE VIEW tx_ringmember_sourcetx_count_sample AS 
    SELECT * 
    FROM (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY n_ringmembers ORDER BY tx_block_height) AS r,
            t.*
        FROM tx_ringmember_sourcetx_count t
        WHERE t.tx_block_height >= 2210720 -- v14
    ) x
    WHERE x.r <= 100;