# Starling Foundries' References and Discussions in support of the metatransactions for Zilliqa project

This repository holds the reference notes and implementations for various scilla smart contracts required to make the metatransactions work in a Zilliqa-native way. [uPort](https://github.com/uport-project/uport-identity#send-a-meta-tx) has made the intial strides but appepars to have moved on from TxRelays.

## Bouncer Proxy

See the [zilliqa-bouncer](https://github.com/starling-foundries/zilliqa-bouncer) repo for more details. At the highest level this server collects and processes the signed metatransactions for batch processing against the on-chain smart contracts found here.

## Proxy Contracts for on-chain resolution

This folder contains the necessary smart contract functions that enable a dapp to utilize in the metatransactions and a bouncer proxy. It shall include a forwarding contract, execution, proxy whitelist and a Scilla reference token example.

## Send-by-Signature Scilla Contract

See the MetaTransactions folder for more details. The corresponding ERC-777 contract enables transaction signers to pre-validate the transaction with their private key, then propogate it in alternative ways that enable delayed or delegated processing and off-chain coordination. All this is possible without the user giving up control of their private key. It will likely prove unecessary in Zilliqa as schnorr multisig can be done without a contract.

## Native MetaTX Scilla Library

The ERC-1776 provides a reference for integration libraries that other smart contract developers can import to enable their dapps to natively support metatransactions. The MetaTransactions folder contains the modified concept for this project.

## proofBadges

This is a non-fungible token that can be distributed by an authorizing entity and then it is non-transferrable except perhaps to burn. It takes inspiration from the OpenProofs concept that is being developed for Ethereum.