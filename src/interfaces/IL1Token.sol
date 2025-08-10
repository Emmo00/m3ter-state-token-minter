// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IL1Token {
    function mint(address to, uint256 amount) external;
    function approve(address spender, uint256 amount) external returns (bool);
}