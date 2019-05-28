# Overview

Adapting the ERC-777 and bouncer contract work from solidity to Zilliqa. This effort illuminated critical differences between ETH and ZIL. Namely, ZIL natively supports Schnorr signatures and protocol buffers, making the ERC-777 contract largely irrelevant. Instead, we can use Schnorr multisignatures for now, and intend to integrate Threshold Secret Sharing from KZEN network in the future.

## Preliminary Architecture

None of the common ethereum solutions are directly translatable to Zilliqa's architecture due to one or more of:

* Scilla cannot process an embedded transaction on-chain.
* Aggregate signatures can not be processed before the smart contract layer.
* Zilliqa desktop miners cannot directly passed validated transactions.

### Concept 1: Multisig and normal broadcast

**Approach:** Multiple signatures for a message: we can use either a regular transaction payload signed, sent to a bouncer proxy acting as provider, which then takes a second signature from the proxy and gets sent to the chain.
**Problems:** Cannot aggregate schnorr signatures within the zilliqa-js-sdk, the bouncer-proxy needs to be able to check signatures against pubkeys, many wallets will find it difficult to transparently route metatransactions to the bouncer and regular transactions to the blockchain as required.

### Concept 2: alternative transaction payload

**Approach:** An alternative message payload is packed by the client with only data, pubkey, _toaddr, and signature being sent to a bouncer-proxy that then encapsulates the entire payload in a second transaction that packages the first message and processes that first message on-chain. This is how most Ethereum meta-transactions processess work.
**Problems:** The messages are passed to scilla in smart contracts as already-unpacked payloads. I do not believe that a second message could be unpacked on-chain and it would certainly make much of the safety guarantees invalid. I imagine something like SQL injection attacks could become prevalent with widespread adoption.

### Concept 3: light-wallet constructed for each relay relationship

**Approach:** Issue wallets to new users, transparently create a Threshold Signature Scheme for the bouncer + each client. Bouncer holds blacklist while whitelist is stored on-chain in the relay contract. To make metaTransfer possible in the token contract it must include arbitrary transfer capabilities from the relayContract. This means ideally the relayContract is deployed by the same account that deployed the token.
**Problems:** TSS from KZEN_Network is not expected for delivery until mid-June.

## Plan of Action

### Phase 0: Zilliqa Core changes

* necessary change of core message protocol as well as sdk transaction payload to split the _senderpubkey field into a _payer and _sender field.
* This  results in it becoming necessary to include two schnorr signatures in the payload so the sender signs the payload except the gasprice and gaslimit fields, while the relayer (payer) signs the entire payload.
* Changes to the sdks as well as the network node are necessary for this to function.

### Phase 1: Realizing a coupled relay and metatransactions concept.

The above changes will enable a fairly simple bouncer proxy that holds a private key corresponding to the _owner of the on-chain relayWallet.scilla. This contract may not be necessary in every case, but it is smart to include it in the flow so that bouncer's can transparently manage allowances, blacklists or whitelists. Much of this could be handled by the bouncer to save gas if transparency is not a primary concern.

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