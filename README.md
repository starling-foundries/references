# Overview

Adapting the ERC-777 and bouncer contract work from solidity to Zilliqa. This effort illuminated critical differences between ETH and ZIL. Namely, the Zilliqa network expects Schnorr signatures and protocol buffers, making the send-by-signature Ethereum workflow largely irrelevant. Instead, we can use Schnorr multisignatures once they are practical on-chain. For now we must rely on a compromised trust model and a trusted operator to enable gasless transactions. Research will be undertaken to integrate Threshold Secret Sharing from KZEN network in the future.

## Preliminary Architecture

None of the common ethereum solutions are directly translatable to Zilliqa's architecture due to one or more of:

* Scilla cannot process an embedded transaction on-chain.
* Aggregate signatures can not be processed before the smart contract layer.
* Zilliqa desktop miners cannot be passed validated transactions directly.

These restrictions make it necessary to implement a trusted operator(s) to effectively live in the bouncer and accept/reject metatransactions based on off-chain logic. This has some desirable properties and the identity of the operator cannot be made secret, thus the trust tradeoffs are warranted by the situation. The operator cannot censor transactions - only refuse them at the metatransaction layer, forcing the sender to pay for gas in ZIL to circumvent.

The below sections describe the subdirectories of this repository as well as the overall multi-pronged approach to making Zilliqa the tokenization platform to beat.

### Concept 1: native metaTX via alternative transaction payload

**Approach:** An alternative message payload is packed by the client with only data, pubkey, _toaddr, and signature being sent to a bouncer-proxy that then encapsulates the entire payload in a second transaction that packages the first message and processes that first message on-chain. This is how most Ethereum meta-transactions processess work. (See ERC-1776, [ERC-865](https://github.com/blockwrkinc/BlockWRKToken/blob/master/contracts/ERC865BasicToken.sol))
**Problems:** The messages are passed to scilla in smart contracts as already-unpacked payloads after being validated by the index (?) nodes. I do not believe that a second message could be unpacked on-chain and it would certainly make much of the safety guarantees invalid. I imagine something like SQL injection attacks could become prevalent with widespread adoption.
**Status:** Work in progress, will be considered functional when the contract transitions can be invoked with a provided bouncer proxy service. Will be complete when suggestions of ERC-1035 are realized as an update to the message protocol. See NativeMetaTransactions directory for WIP.

### Concept 2: [EIP-965](https://github.com/ethereum/EIPs/issues/965): Send-by-Signature extension
**Approach:** This workflow is achievable today but has not been chosen as the standard implementation. It adds gasless transfers to the ERC-777 contract (itself an incremental improvement on ERC-20). Secondary benefits such as pre-authorized cheques and agreements are also compelling but won't be prioritized for inital release.
**Problems:** This contract is more complex, making security concerns far higher. Beyond that the stakes are higher - with most metatransactions implementations both parties have to engage to do the transaction. For this version the operator is very completely trusted by every token holder - a rougue operator could compromise an entire token. 
**Status:** This is of interest but not presently pursued. The first release of metatransactions should be as robust as possible - even if that means leaving cool features like cheques out. 


### Concept 3: Multisig and normal broadcast

**Approach:** Multiple signatures for a message: we can use either a regular transaction payload signed, sent to a bouncer proxy acting as provider, which then takes a second signature from the proxy and gets sent to the chain.
**Problems:** Cannot aggregate schnorr signatures within the zilliqa-js-sdk, the bouncer-proxy needs to be able to check signatures against pubkeys, many wallets will find it difficult to transparently route metatransactions to the bouncer and regular transactions to the blockchain as required. Further to ensure security one of the signatories must broadcast the message - creating a natural power imbalance between the signatories.
**Status:** Abandoned indefinitely. 

### Concept 4: native metaTX via alternative transaction payload

**Approach:** An alternative message payload is packed by the client with only data, pubkey, _toaddr, and signature being sent to a bouncer-proxy that then encapsulates the entire payload in a second transaction that packages the first message and processes that first message on-chain. This is how most Ethereum meta-transactions processess work. (See ERC-1776, [ERC-865](https://github.com/blockwrkinc/BlockWRKToken/blob/master/contracts/ERC865BasicToken.sol))
**Problems:** The messages are passed to scilla in smart contracts as already-unpacked payloads after being validated by the index (?) nodes. I do not believe that a second message could be unpacked on-chain and it would certainly make much of the safety guarantees invalid. I imagine something like SQL injection attacks could become prevalent with widespread adoption.
**Status:** Shelved until the suggestions of ERC-1035 are realized as an updage to the message protocol. See NativeMetaTransactions directory for WIP.

### Concept 5: light-wallet constructed for each relay relationship

**Approach:** Issue wallets to new users, transparently create a Threshold Signature Scheme for the bouncer + each client. Bouncer holds blacklist while whitelist is stored on-chain in the relay contract. To make metaTransfer possible in the token contract it must include arbitrary transfer capabilities from the relayContract. This means ideally the relayContract is deployed by the same account that deployed the token.
**Problems:** TSS from KZEN_Network is not expected for delivery until mid-June.
**Status:** Pursued as a non-deliverable research process with the intention of ensuring that the final metatransactions standard is fully compatible with TSS.



## Plan of Action
- [ ] Scilla implementation of ERC865
- [ ] An RPC-based bouncer that encapsulates and signs recieved transactions
- [ ] Deployment tools for the RPC bouncer (.env, dockerfile)
- [ ] A whitelist for approving metatransaction participants
- [ ] Middleware to validate transactions
- [ ] RPC forward to mainchain function
- [ ] Documentation
- [ ] An example with a reference scilla contract.
- [ ] OpenProofs preliminary port

## Future Potential

### Zilliqa Core changes

* necessary change of core message protocol as well as sdk transaction payload to split the _senderpubkey field into a _payer and _sender field.
* This  results in it becoming necessary to include two schnorr signatures in the payload so the sender signs the payload except the gasprice and gaslimit fields, while the relayer (payer) signs the entire payload.
* Changes to the sdks as well as the network node are necessary for this to function.

* Bouncer-Proxy to handle gassless transactions, hold wallet and target the corresponding relay scilla contract.

* Relay scilla contract that is now optional for gassless transactions, although for advanced metaTx usecases will prove to be necessary.

* provided metaTranfer scilla library that enables any tokenizing contract to provide a native metatransactions option that does not split or allow later discrimination between transaction types.

### Phase N: Future Refinement

* The structure of the project makes it desirable to isolate the bouncer-proxy somewhat from the rest of a dapp's hosted infrastructure, so refinement to the control harness would probably be beneficial.

* The stated architecture does not allow a sender to pay for gas in the transaction token, future work will be required to enable that function.

* The TSS functionality could still prove valuable in providing controlled wallets for inexperienced or uninterested clients. With deeper integration it will also enable the above alternative incentive structure.

* decentralizing a network of bouncer relays is an ongoing effort in ethereum, probably futile but worth considering.

* Bouncer as a service API

## Prior Art

[EIP-777: Renewed Token Standard compatible with ERC1820](https://eips.ethereum.org/EIPS/eip-777)

[EIP-965: Complex, ERC-777 compatible, general cheque signing without bouncer](https://github.com/ethereum/EIPs/issues/965)

[issue with details](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/973)
[OpenZeppelin simpler bouncer contract](contracts/access/SignatureBouncer.sol)

[EIP-1077: General Execute of Signed Messages](https://github.com/alexvandesande/EIPs/blob/ee2347027e94b93708939f2e448447d030ca2d76/EIPS/eip-1077.md)

[potentially deprecated: Status IdentityGasRelay](https://github.com/status-im/contracts/blob/73-economic-abstraction/contracts/identity/IdentityGasRelay.sol)

[[WIP] Add eth_signTypedData as a standard for machine-verifiable and human-readable typed data signing with Ethereum keys #712](https://github.com/ethereum/EIPs/pull/712)
[example](https://github.com/wighawag/eip712-origin/blob/master/src/Example.sol#L144)

[ERC-1654 Dapp-wallet authentication process with contract wallets support #1654](https://github.com/ethereum/EIPs/issues/1654)

## known risks

For the ERC-865 implementation if we are not careful to either include account nonces or only allow one bouncer per token then the sender of a metatransaction can double-spend their tokens in different shards.