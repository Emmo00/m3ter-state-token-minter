// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MockRollup} from "../src/RollupMock.sol";

contract UpdateRollupBalance is Script {
    function run() external {
        // === CONFIG ===
        address rollupAddr = vm.envAddress("ROLLUP");
        uint256 tokenId = vm.envUint("TOKEN_ID"); // index to update
        uint48 newBalance = uint48(vm.envUint("NEW_BALANCE"));
        uint256 anchorBlock = block.number; // you can also pass this via env if needed
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        MockRollup rollup = MockRollup(rollupAddr);

        // 1. Get the current blob for latest chainLength
        uint256 currentIndex = rollup.chainLength();
        bytes memory accountBlob = rollup.rawAccountBlob(currentIndex);

        // 2. Make sure blob is big enough
        uint256 offset = (tokenId == 0) ? 0 : (tokenId * 6) - 1;
        if (accountBlob.length < offset + 6) {
            // expand the blob if needed
            bytes memory expanded = new bytes(offset + 6);
            for (uint256 i = 0; i < accountBlob.length; i++) {
                expanded[i] = accountBlob[i];
            }
            accountBlob = expanded;
        }

        // 3. Write the new balance in big-endian order
        for (uint256 i = 0; i < 6; i++) {
            accountBlob[offset + (5 - i)] = bytes1(uint8(newBalance >> (8 * i)));
        }

        // 4. Commit the new state (empty nonce blob here)
        bytes memory nonceBlob = rollup.rawNonceBlob(currentIndex);
        rollup.commitState(anchorBlock, accountBlob, nonceBlob, "");

        vm.stopBroadcast();
    }
}
