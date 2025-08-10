
# m3ter-state-token-minter

This project is a suite of smart contracts implementing L1 to L2 minting of the m3ter state as tokens. It enables bridging and minting operations between Layer 1 and Layer 2, as a m3terchain application.

## Contracts

- `L1MinterAndBridger.sol`: Handles minting and bridging logic on Layer 1.
- `L1Token.sol`: ERC20 token contract for Layer 1.
- `L2Token.sol`: ERC20 token contract for Layer 2.
- `PowerAggreements.sol`: NFT storage for m3ter NFTs on Layer 1, holds info about who should get the minted tokens.
- `RollupMock.sol`: Mock contract for rollup testing.

## Usage


This project uses [Foundry](https://book.getfoundry.sh/) for development, testing, and deployment.

## More Information

For more details on the m3tering protocol and m3terchain, see the [official documentation](https://docs.m3ter.ing/technical-specs/v2.0-specs).
