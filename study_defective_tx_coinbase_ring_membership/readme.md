# Study: Defective Transaction Coinbase Ring Membership
Neptune & Anonymous, 2021-02-15

## Problem statement
For some given transaction defect, is the rate of coinbase outputs among ring members of transactions with the defect approximately the same as the rate of coinbase outputs among outputs in general?

1. Choose a defect and take the latest N transactions with that defect and record all their ring members. If some of them occur more them once, record them every time.

2. Note the block height of
    a) the oldest among these ring members (let's call that block height A) and
    b) the youngest among these ring members (let's call that block height B).

3. Take the part of the blockchain from block A to block B and divide it into sections consisting of Z blocks each and call them S_1,...,S_M (if B-A is not divisible by Z, make S_1 a little larger).

4. For each S_i, we find the following data:  
    a) `n_ringmembers`, the total number of ring members that we recorded in 1. that originate from a block in S_i  
    b) `n_coinbase_ringmembers`, the number of ring members we recorded in 1. that are coinbase outputs and originate from a block in S_i  
    c) `e_tx_n_outputs`, the total number of outputs of transactions that appear in S_i  
    d) `e_coinbase_tx_n_outputs`, the total number of coinbase outputs of transactions that appear in S_i  