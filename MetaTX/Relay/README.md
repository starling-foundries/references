# Relay and operator concerns

## Overview
The use of a relay or signature bouncer is a fairly common pattern for Ethereum development. Zilliqa has all the tools necessary to adapt this pattern for scilla devs. 

## Prior Art

## Technology Survey:
I studied several options for creating a relay and settled on several central concerns and one reasonable solution. 
First, Zilliqa uses .proto definition files but not gRPC. Secondly Zilliqa has built-in schnorr signatures. These factors together mean we can have some reasonably secure off-chain message passing that bridges authority and context into smart contract operation. 

To that end, I explored these alternatives and dismissed them because...

* Express RPC: Not enough code generation, lack of built in security means we're starting from scratch.
* gRPC service: gRPC would require a lot of concessions regarding infrastructure and does not support HTTP/1.1, making it more challenging to integrate as a service API.
* NEST.js: has an excellent scaffolding tool, typescript, etc. However any wallet or website that would use this bouncer would need to understand the concept of observables to integrate this functionality.
* Twirp: Twirp takes a .proto file and scaffolds a large portion of a JSON-RPC with reasonable practices in place. This is ideal for also generating a client for other platforms or the browser.