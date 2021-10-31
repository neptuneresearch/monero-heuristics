Multiple Ring Members From Same Transactions, Within Same Transaction Or Transaction Input  
Neptune 2021-10-26

# Questions
a) how often it's been the case that a transaction has exactly 2 ring members (regardless if those ring members belong to the same input or to different inputs) that come from the same transaction.  
b) how often it's been the case that a transaction has exactly 3 ring members (regardless if those ring members belong to the same input or to different inputs) that come from the same transaction.  
c) how often it's been the case that a transaction has 4 or more ring members (regardless if those ring members belong to the same input or to different inputs) that come from the same transaction.  
d) how often it's been the case that a case from above appears twice or more often in one transaction (i.e., that a transaction has 2 or more ring members that come from the same transaction and another 2 or more ring members that also come from the same transaction (but from a different one than from which the first mentioned 2 or more ring members come from))  
e) Have these numbers changed over time? (maybe after changes in the decoy selection algorithm happened).

Given: RingCT transactions only

# Answers
1. Count each case from Question A,B,C; also present as % of transactions from total  
    **Release File:** `csv_txringmember_sourcetx_count`

    - Same or different input: `tx_ringmember_sourcetx_count_dist.csv`
    - Same input: `tx_ringmember_sourcetx_count_sameinput_dist.csv`

    - Columns always included:
        - n_ringmembers: Number of ringmembers from same source transaction

    - Same or different input columns:
        - n_tx: Number of transactions where this occurred
        - n_tx_pct: n_tx as percentage of transactions out of total of transactions for all values for n_ringmembers > 1
        - n_tx_pct_rct: n_tx as percentage of RingCT transactions in entire blockchain

    - Same input columns:
        - n_txinput: Number of transaction inputs where this occurred
        - n_txinput_pct: n_txinput as percentage of transaction inputs out of total of transaction inputs for all values for n_ringmembers > 1
        - n_txinput_pct_rct: n_txinput as percentage of RingCT transaction inputs in entire blockchain

2. Question D: repeat #1 for "multiple" variant  
    **Release File:** `csv_txringmember_sourcetx_count`

    - Same or different input: `tx_ringmember_sourcetx_count_multiple_dist.csv`
    - Same input: `tx_ringmember_sourcetx_count_sameinput_multiple_dist.csv`

    - Columns:
        - n_ringmember_sourcetx: Number of source transactions that were used in > 1 transaction inputs, for all transaction inputs 
            - (will double count i.e. if same tx was used for 2 ringmembers in different inputs A and B, it will count 2 source transactions)
        - n_tx: Number of transactions where this occurred
        - n_tx_pct: Percentage of transactions in this data set
        - n_tx_pct_rct: Percentage of RingCT transactions in entire blockchain

3. Question E: query using block_height and monero_version HF ranges  
    **Release File:** `csv2_txringmember_sourcetx_count`

    - Same or different input: `tx_ringmember_sourcetx_count_version.csv`
        - RingCT transactions per version: `tx_input_list_rct_count_tx_version.csv`
    - Same input: `tx_ringmember_sourcetx_count_sameinput_version.csv`
        - RingCT transactions per version: `tx_input_list_rct_count_ringmember_version.csv`

    - Columns always included:
        - version: Hard fork version number
        - height: Start height for hard fork
        - n_ringmembers: Number of ringmembers from same source transaction

    - Same or different input columns:
        - n_tx: Number of transactions where this occurred
        - [v2] n_tx_pct_rct_version: Percentage of all RingCT transactions for this version

    - Same input columns:
        - n_txinput: Number of transaction inputs where this occurred
        - [v2] n_txinputs_pct_rct_version: Percentage of all RingCT transaction inputs for this version

4. Rerun #1 and #2 only for the current hard fork v14  
    **Release File:** `csv_3_txringmember_sourcetx_count`

    - `tx_ringmember_sourcetx_count_dist_v14.csv`
    - `tx_ringmember_sourcetx_count_multiple_dist_v14.csv`
    - `tx_ringmember_sourcetx_count_sameinput_dist_v14.csv`
    - `tx_ringmember_sourcetx_count_sameinput_multiple_dist_v14.csv`

    - Source: `tx_ringmember_sourcetx_count_v14.sql`

# Release Summary

**Release File Group**: txringmember_sourcetx_count

| Release file prefix | Description | Format |
| - | - | - |
| csv | Initial release | CSV |
| csv_2 | Updates answer #3: adds pct_rct_version to version distributions | CSV |
| csv_3 | Reruns answer #1 and #2 only for the current hard fork v14 | CSV |


# Design
1. Metrics of current ring-membership-sql data, for calculating percentages:
    - Height range (tx_ringmember_list_block_height_max) = 2457499
    - Number of RingCT transactions (tx_input_list_rct_count_tx) = 15647807
    - Number of RingCT transaction inputs (tx_input_list_rct_count_ringmember) = 34593457

2. Base data sets (Materialized Views):
    - tx_ringmember_sourcetx_count:
        - With respect to tx_ringmember_list,
        - where one row is one ringmember in one transaction input:
        - give the number of ringmembers (uses) per source transaction (n_ringmembers) per transaction,
        - where the source transaction was used for > 1 ringmembers in the transaction (within same input or across - different inputs)
        - (since = 1 would be used once, the common and not-special case).

    - tx_ringmember_sourcetx_count_multiple:
        - With respect to tx_ringmember_sourcetx_count,
        - where one row is a { transaction, ringmember source transaction } pair with n_ringmembers:
        - give the number of re-used source transactions (n_ringmember_sourcetx) per transaction,
        - where the ring transaction re-used > 1 source transactions for ringmembers
        - (since = 1 means only 1 source transaction was re-used for some n_ringmembers, not a "multiple" case).

    - tx_ringmember_sourcetx_count_sameinput:
        - With respect to tx_ringmember_list,
        - where one row is one ringmember in one transaction input:
        - give the number of ringmembers (uses) per source transaction (n_ringmembers) per transaction input,
        - where the source transaction was used for > 1 ringmembers in the transaction input
        - (since = 1 would be used once, the common and not-special case).

    - tx_ringmember_sourcetx_count_sameinput_multiple: 
        - With respect to tx_ringmember_sourcetx_count_sameinput,
        - where one row is a { transaction input, ringmember source transaction } pair with n_ringmembers:
        - give the number of re-used source transactions (n_ringmember_sourcetx) per transaction,
        - where the ring transaction re-used > 1 source transactions for ringmembers
        - (since = 1 means only 1 source transaction was re-used for some n_ringmembers, not a "multiple" case).

    - Extra data set: tx_ringmember_sourcetx_count_sameinput_multiple_byinput:
        - Alternate version of tx_ringmember_sourcetx_count_sameinput_multiple; 
        - only one View is implemented: tx_ringmember_sourcetx_count_sameinput_multiple_byinput_txsummary.
        - With respect to tx_ringmember_sourcetx_count_sameinput,
        - where one row is a { transaction input, ringmember source transaction } pair with n_ringmembers:
        - give the number of re-used source transactions (n_ringmember_sourcetx) per transaction input,
        - where the source transaction was used for > 1 ringmembers in the transaction input
        - (since = 1 would be used once, the common and not-special case).
