// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IL1StandardBridge} from "./interfaces/IL1StandardBridge.sol";
import {IL1Token} from "./interfaces/IL1Token.sol";
import {IRollup} from "./interfaces/IRollup.sol";
import {PowerAggreements} from "./PowerAggreements.sol";

contract L1MinterAndBridger {
    address public immutable l1Token;
    address public immutable l2Token;
    address public immutable l1Bridge;
    address public immutable owner;
    PowerAggreements public immutable powerAggreements;
    address public immutable rollupAddress;

    mapping(uint256 => uint256) public tokenIdToAmountMinted;

    constructor(
        address _powerAggreements,
        address _rollupAddress,
        address _l1Token,
        address _l2Token,
        address _l1Bridge
    ) {
        powerAggreements = PowerAggreements(_powerAggreements);
        rollupAddress = _rollupAddress;
        l1Token = _l1Token;
        l2Token = _l2Token;
        l1Bridge = _l1Bridge;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "L1MinterAndBridger: Only owner");
        _;
    }

    function mintAndBridge(uint256 m3terTokenId, uint32 l2Gas, bytes calldata data) external onlyOwner {
        require(powerAggreements.m3terToPowerAgreement(m3terTokenId), "L1MinterAndBridger: Invalid m3ter token ID");

        // Get cumulative balance from rollup contract
        bytes6 accountData = IRollup(rollupAddress).account(m3terTokenId);
        uint256 cumulativeBalance = uint256(uint48(accountData));

        require(cumulativeBalance > 0, "L1MinterAndBridger: Insufficient balance");

        uint256 balanceDelta = uint256(cumulativeBalance) - uint256(tokenIdToAmountMinted[m3terTokenId]);

        // encode balance with token ID
        uint256 amount = encodeBalanceWithTokenId(balanceDelta, m3terTokenId);

        // get to address (owner of power aggreement NFT)
        address to = powerAggreements.ownerOf(m3terTokenId);

        // Mint tokens to this contract
        IL1Token(l1Token).mint(address(this), amount);

        // Approve L1StandardBridge to spend tokens
        IL1Token(l1Token).approve(l1Bridge, amount);

        // Bridge tokens to L2
        IL1StandardBridge(l1Bridge).depositERC20To(l1Token, l2Token, to, amount, l2Gas, data);
    }

    function encodeBalanceWithTokenId(uint256 balance, uint256 tokenId) internal view returns (uint256) {
        // l1 token decimals
        uint256 l1TokenDecimals = IL1Token(l1Token).decimals();
        uint256 amount = balance * (10 ** l1TokenDecimals);
        // shift by 12 bits
        return (amount << 12) | tokenId;
    }
}
