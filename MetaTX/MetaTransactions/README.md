# Overview

The goal of a metatransaction offering is to foremost abstract away dealing with gas costs in native fuel for the sake of easier onboarding of early users. This directory contains the necessary components to make the developer experience similarly transparent. The ultimate goal is to provide a scilla library that can be included in an arbitrary token contract to enable a relayer to submit valid transactions to that contract in a secure and trustless manner.

## Preliminary Architecture

## Roadblocks

## Prior Art
[ERC-865: Meta Transaction integration for gas payment in erc20 tokens](https://github.com/ethereum/EIPs/issues/865)
[ERC-1776 Native Meta Transactions](https://github.com/wighawag/EIPs/blob/41055a88efb46d9cf5797764b02554bdb26672f0/EIPS/eip-native-meta-transactions.md)

[example ethereum token contract with metaTx integration](https://github.com/pixowl/thesandbox-contracts/blob/master/src/Sand/erc20/ERC20MetaTxExtension.sol) solidity contract

[uPort TxRelay](https://github.com/uport-project/uport-identity/blob/develop/contracts/TxRelay.sol) 