// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IL1StandardBridge} from "./interfaces/IL1StandardBridge.sol";
import {IL1Token} from "./interfaces/IL1Token.sol";

contract L1MinterAndBridger {
    address public immutable l1Token;
    address public immutable l2Token;
    address public immutable l1Bridge;
    address public immutable owner;

    constructor(address _l1Token, address _l2Token, address _l1Bridge) {
        l1Token = _l1Token;
        l2Token = _l2Token;
        l1Bridge = _l1Bridge;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "L1MinterAndBridger: Only owner");
        _;
    }

    function mintAndBridge(address to, uint256 amount, uint32 l2Gas, bytes calldata data) external onlyOwner {
        // Mint tokens to this contract
        IL1Token(l1Token).mint(address(this), amount);

        // Approve L1StandardBridge to spend tokens
        IL1Token(l1Token).approve(l1Bridge, amount);

        // Bridge tokens to L2
        IL1StandardBridge(l1Bridge).depositERC20To(l1Token, l2Token, to, amount, l2Gas, data);
    }
}
