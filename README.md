# Starling Foundries' References and Discussions in support of the metatransactions for Zilliqa project

This repository holds the reference notes and implementations for various scilla smart contracts required to make the metatransactions work in a Zilliqa-native way. 

## Bouncer Proxy

See the [zilliqa-bouncer](https://github.com/starling-foundries/zilliqa-bouncer) repo for more details. At the highest level this server collects and processes the signed metatransactions for batch processing against the on-chain smart contracts found here.

## Proxy Contracts for on-chain resolution

This folder contains the necessary smart contract functions that enable a dapp to utilize in the metatransactions and a bouncer proxy. It shall include a forwarding contract, execution, proxy whitelist and a Scilla reference token example.

## Send-by-Signature Scilla Contract

See the ZRC-777 folder for more details. This contract enables transaction signers to pre-validate the transaction with their private key, then propogate it in alternative ways that enable delayed or delegated processing and off-chain coordination. All this is possible without the user giving up control of their private key.

## Native MetaTX Scilla Library

The ZRC-1776 reference for integration libraries that other smart contract developers can import to enable their dapps to natively support metatransactions.

## proofBadges

This is a non-fungible token that can be distributed by an authorizing entity and then it is non-transferrable. It takes inspiration from the OpenProofs concept that is being developed for Ethereum.