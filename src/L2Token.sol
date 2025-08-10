// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "optimism/packages/contracts-bedrock/src/universal/OptimismMintableERC20.sol";


contract L2Token is OptimismMintableERC20 {
    uint256 public totalBridgedBalance; // Example custom state variable

    constructor(address _l2Bridge, address _l1Token)
        OptimismMintableERC20(_l2Bridge, _l1Token, "L2Token", "L2T", 18)
    {
    }

    // Override mint to add custom logic
    function mint(address _to, uint256 _amount) public override {
        require(msg.sender == BRIDGE, "L2Token: Only L2Bridge can mint");
        _mint(_to, _amount); // Use _mint from ERC20
        // Custom post-mint logic
        totalBridgedBalance += _amount; // Track total bridged tokens
    }
}