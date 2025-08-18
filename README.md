
# m3ter-state-token-minter

This project is a suite of smart contracts implementing L1 to L2 minting of the m3ter state as tokens. It enables bridging and minting operations between Layer 1 and Layer 2, as a m3terchain application.


## Contracts

- `L1MinterAndBridger.sol`: Orchestrates minting of L1 tokens and bridges them to L2, using rollup state and power agreements.
- `L1Token.sol`: ERC20 token for Layer 1, with a minter role for controlled minting.
- `L2Token.sol`: Optimism-compatible ERC20 token for Layer 2, mintable by the L2 bridge, tracks total bridged balance.
- `PowerAggreements.sol`: Manages deposited m3ter NFTs and their ownership, tracks which NFTs are eligible for power agreements and who owns them.
- `RollupMock.sol`: Mock rollup contract for testing, simulates state and account data for m3ter tokens.
- `CarbonCredits.sol`: ERC721 contract that mints carbon credit NFTs based on energy usage reported by the rollup and m3ter NFT ownership.
- `M3terNFTMock.sol`: Mock ERC721 contract for m3ter NFTs, used for testing and development.



## Requirements

- [Foundry](https://book.getfoundry.sh/) (for Solidity development, testing, and deployment)
- Node.js and npm (for some scripts, optional)

## Installation

1. **Install Foundry:**
	```bash
	curl -L https://foundry.paradigm.xyz | bash
	foundryup
	```
2. **Clone the repository:**
	```bash
	git clone https://github.com/Emmo00/m3ter-state-token-minter.git
	cd m3ter-state-token-minter
	```
3. **Install dependencies:**
	```bash
	forge install
	```

## Usage

### Formatting
Format all contracts:
```bash
forge fmt
```

### Testing
Run all tests:
```bash
forge test
```

### Deployment
Deploy contracts using the provided script (edit `PRIVATE_KEY` and RPC URLs as needed):
```bash
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --broadcast --private-key $PRIVATE_KEY
```

### Environment Variables
Set the following environment variables for deployment and testing:
- `PRIVATE_KEY`: Your deployer wallet private key
- `SEPOLIA_URL`: RPC URL for Ethereum Sepolia
- `OP_SEPOLIA_URL`: RPC URL for Optimism Sepolia
- `ETHERSCAN_API_KEY`: (optional) for contract verification

## Project Structure

- `src/`: Main Solidity contracts
- `test/`: Foundry test contracts
- `script/`: Deployment and utility scripts
- `lib/`: External dependencies

## More Information

## More Information

For more details on the m3tering protocol and m3terchain, see the [official documentation](https://docs.m3ter.ing/technical-specs/v2.0-specs).
