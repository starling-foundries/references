# Overview

This scilla contract implements most of the ERC-1776 and ERC-865 functionality. Currently it is missing: 

- [ ] create a hash of payload in-contract
- [ ] validate pubkey, sig against this payload
- [ ] validate contract address
- [ ] Account nonces or a single bouncer limitation.

NOTE: if a metaTransfer function is not included in the initial contract it is difficult to incorporate the gasless functionality after it launches. 

## Prior Art
[ERC-865: Meta Transaction integration for gas payment in erc20 tokens](https://github.com/ethereum/EIPs/issues/865)
[ERC-1776 Native Meta Transactions](https://github.com/wighawag/EIPs/blob/41055a88efb46d9cf5797764b02554bdb26672f0/EIPS/eip-native-meta-transactions.md)

[example ethereum token contract with metaTx integration](https://github.com/pixowl/thesandbox-contracts/blob/master/src/Sand/erc20/ERC20MetaTxExtension.sol) solidity contract

[uPort TxRelay](https://github.com/uport-project/uport-identity/blob/develop/contracts/TxRelay.sol) 