// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import {PowerAggreements} from "../src/PowerAggreements.sol";
import {L1MinterAndBridger} from "../src/L1MinterAndBridger.sol";
import {MockRollup} from "../src/RollupMock.sol";
import {L1Token} from "../src/L1Token.sol";
import {L2Token} from "../src/L2Token.sol";
import {M3terNFTMock} from "../src/M3terNFTMock.sol";

contract Deploy is Script {
    address l1Bridge = 0xFBb0621E0B23b5478B630BD55a5f21f67730B0F1; // Optimism Standard bridge on sepolia ETH
    address l2Bridge = 0x4200000000000000000000000000000000000010; // superchain L2 standard bridge
    // address m3terNFT = 0x40a36C0eF29A49D1B1c1fA45fab63762f8FC423F; // m3ter NFT on sepolia ETH

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        uint256 sepoliaFork = vm.createSelectFork("sepolia");
        vm.startBroadcast(pk);
        // Deploy Mock NFT contract
        address m3terNFT = address(new M3terNFTMock());
        // Deploy PowerAggreements contract
        address powerAggreements = address(new PowerAggreements(m3terNFT));
        // Deploy Rollup contract
        address rollupAddress = address(new MockRollup());
        // Deploy L1Token contract
        address l1Token = address(new L1Token());
        vm.stopBroadcast();

        // deploy L2 Contracts
        vm.createSelectFork("optimism-sepolia");
        vm.startBroadcast(pk);
        address l2Token = address(new L2Token(l2Bridge, l1Token));
        vm.stopBroadcast();

        vm.selectFork(sepoliaFork);
        vm.startBroadcast(pk);

        // Debug: Check who is the minter of L1Token
        address l1TokenMinter = L1Token(l1Token).minter();
        console.log("L1Token minter:", l1TokenMinter);
        console.log("Current msg.sender:", msg.sender);

        // Deploy L1MinterAndBridger contract
        address minterAndBridger = address(
            new L1MinterAndBridger(
                powerAggreements,
                rollupAddress,
                l1Token,
                l2Token,
                l1Bridge
            )
        );
        // set minter as the l1minterandbridger
        L1Token(l1Token).setMinter(minterAndBridger);
        vm.stopBroadcast();
    }
}
