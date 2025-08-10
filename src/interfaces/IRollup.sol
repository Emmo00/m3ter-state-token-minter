// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRollup {
    function account(uint256 tokenId) external view returns (bytes6);
}
