# If a transaction has multiple inputs, do they all have the same ring size?
Author: Neptune  
Created: 2021-08-08  
Updated: 2022-02-13  

## Analysis
We need a table of the ring sizes of all transaction inputs (both Pre-RingCT and RingCT), which has at least these columns:

- `block_height`: to tell when the transaction happened
- `tx_hash` or `tx_index`: to distinguish transactions
- `vin_index`: to distinguish transaction inputs
- `ring_size`: the target data

For this, we can use `tx_input_ring_stat` in the `monero-sql` package [[1]](#References) (see category `ringsql_stat`).

With such a dataset, we can create a query `tx_input_ring_size_sametx_diffinput_diffringsize` which for some transaction input A, finds another transaction input B that has:  

1. Same transaction (`A.block_height = B.block_height` and `A.tx_index = B.tx_index`)
2. Greater ring size (`A.ring_size < B.ring_size`)

Condition #2 has two desired side-effects:  
- The greater of the two ring sizes will end up in `ring_size_B`.  
- We won't need another condition to differentiate the input index, i.e. `A.vin_index <> B.vin_index`, because that will be inherently guaranteed: A and B must be different because the ring size of either cannot be less than itself. 


## Results

#### How many occurrences?
- 2478 transactions
- 2884303 transaction inputs

#### What height range or hard fork versions has it occurred in?
- Minimum height occurred at: 3003 = during v1
- Maximum height occurred at: 1118879 = between v2 and v3
 
Hard Fork versions relevant to the result height range:
- v1, 0
- v2, 1009827
- v3, 1141317
- v4, 1220516

Hard Fork versions which mention ring size rule changes:
- v6, 1400000: Allow only RingCT transactions, allow only >= ringsize 5
- v7, 1546000: ringsize >= 7
- v8, 1685555: fixed ringsize 11

Answer:
- Last occurrence was between v2 and v3.
- Therefore, did not happen at a hard fork.
- Otherwise, no proof of any specific reason to stop at that height.
- As of v8, due to fixed ringsize 11 rule, it is no longer possible.


## References
[1] GitHub - neptuneresearch/monero-sql. [https://github.com/neptuneresearch/monero-sql](https://github.com/neptuneresearch/monero-sql).