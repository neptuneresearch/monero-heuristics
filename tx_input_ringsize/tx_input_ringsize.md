# If a transaction has multiple inputs, do they all have the same ring size?
Neptune 2021-08-08

## Analysis
First, create a helper table `tx_input_ring_size`: list the ring sizes of all transaction inputs (both Pre-RingCT and RingCT).

- `height`
- `tx_index`
- `vin_index`
- `ring_size`

Then we create the query `tx_input_ring_size_sametx_diffinput_diffringsize`, which for some transaction input A, finds another transaction input B that has:  

- Same transaction (`A.height = B.height` and `A.tx_index = B.tx_index`)
- Different input (`A.vin_index <> B.vin_index`)
- Different ring size (`A.ring_size <> B.ring_size`)


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