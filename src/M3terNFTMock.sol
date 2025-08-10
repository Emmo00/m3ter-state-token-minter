// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract M3terNFTMock is ERC721 {
    uint256 private _currentTokenId;

    constructor() ERC721("M3terNFT", "M3T") {}

    function mint(address to) external returns (uint256) {
        _currentTokenId++;
        _mint(to, _currentTokenId);
        return _currentTokenId;
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return super.ownerOf(tokenId);
    }

    function totalSupply() external view returns (uint256) {
        return _currentTokenId;
    }
}