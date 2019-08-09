# The Send By Signature Approach

## Send-by-Signature

## Zilliqa Architecture concerns
The Zilliqa protocol relies on a few protobuf .proto files, but it does not use gRPC. The standard RPCs that a developer of dapps would interact with should all be JSON-RPCs. We can thus make assumptions and reuse code to accelerate our development. 
In Ethereum a send-by-signature extension can happen off chain or on-chain. Transaction malleability is then a central concern and off-chain distributed operations are known to introduce odd corner cases and make security challenging. Thankfully, Schnorr signatures and the typed proto definitions make this much easier to accomplish safely off-chain. For performance, flexibility and costs we will implement metatransactions off-chain with the help of an operator that effectively relays transactions. This method is excellent for dapps that already offer centralized services to users and have unilateral control over the contract.

## Implementation

We will rewrite provided ERC-777.scilla contract to include the [ERC-965](https://github.com/ethereum/EIPs/issues/965) extensions this will allow us to run an approved operator node that can make decisions about transactions and operate tokens in a constrained way on behalf of users. This will partner well with a [twirp](https://twitchtv.github.io/twirp/) RPC scaffolding tool that enables many anticipated use-cases with minimal configuration.

## Progress
