// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract L1Token is ERC20 {
    address public minter;

    constructor() ERC20("L1Token", "L1T") {
        minter = msg.sender;
        _mint(msg.sender, 1000000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "L1Token: Only minter can call");
        _;
    }

    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }

    function setMinter(address _minter) public onlyMinter {
        minter = _minter;
    }
}
