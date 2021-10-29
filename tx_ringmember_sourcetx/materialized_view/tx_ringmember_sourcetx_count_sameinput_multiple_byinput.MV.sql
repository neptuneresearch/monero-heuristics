-- Row level: transaction input
CREATE MATERIALIZED VIEW tx_ringmember_sourcetx_count_sameinput_multiple_byinput AS (
    SELECT
        tx_block_height,
        tx_hash,
        tx_vin_index,
        COUNT(1) AS n_ringmember_sourcetx
    FROM tx_ringmember_sourcetx_count_sameinput
    GROUP BY tx_block_height, tx_hash, tx_vin_index
    HAVING COUNT(tx_hash) > 1
) WITH NO DATA;

-- Runtime: 1s
REFRESH MATERIALIZED VIEW tx_ringmember_sourcetx_count_sameinput_multiple_byinput;

CREATE VIEW tx_ringmember_sourcetx_count_sameinput_multiple_byinput_txsummary AS
    WITH count_inputs AS (
        SELECT
            tx_block_height,
            tx_hash,
            COUNT(1) AS n_tx_inputs
        FROM tx_ringmember_sourcetx_count_sameinput_multiple_byinput
        GROUP BY tx_block_height, tx_hash
    )
    SELECT
        M.tx_block_height,
        M.tx_hash,
        CI.n_tx_inputs,
        SUM(M.n_ringmember_sourcetx) AS n_ringmember_sourcetx
    FROM tx_ringmember_sourcetx_count_sameinput_multiple_byinput M
    JOIN count_inputs CI 
        ON CI.tx_block_height = M.tx_block_height
        AND CI.tx_hash = M.tx_hash
    GROUP BY M.tx_block_height, M.tx_hash, CI.n_tx_inputs
    ORDER BY M.tx_block_height ASC;