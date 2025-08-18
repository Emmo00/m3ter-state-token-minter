// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract PowerAggreements is IERC721Receiver {
    address public immutable m3terNFT;

    // mapping for m3ter token ID to Power aggrement token id check
    mapping(uint256 => bool) public m3terToPowerAgreement;
    // m3ter id to owner
    mapping(uint256 => address) public m3terToOwner;

    constructor(address _m3terNFT) {
        m3terNFT = _m3terNFT;
    }

    function depositM3terNFT(uint256 tokenId) external {
        require(IERC721(m3terNFT).ownerOf(tokenId) != address(0), "Invalid NFT");
        require(m3terToPowerAgreement[tokenId] == false, "Already deposited");

        _depositNFT(tokenId, msg.sender);
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        require(m3terToPowerAgreement[tokenId] == true, "No agreement found");
        return m3terToOwner[tokenId];
    }

    function transferAggreement(uint256 tokenId, address to) external {
        require(m3terToPowerAgreement[tokenId] == true, "No agreement found");
        require(m3terToOwner[tokenId] == msg.sender, "Not the owner");

        m3terToOwner[tokenId] = to;
        IERC721(m3terNFT).safeTransferFrom(address(this), to, tokenId);
    }

    function withdrawNFT(uint256 tokenId, address to) external {
        require(m3terToPowerAgreement[tokenId] == true, "No agreement found");
        require(m3terToOwner[tokenId] == msg.sender, "Not the owner");

        m3terToPowerAgreement[tokenId] = false;
        m3terToOwner[tokenId] = address(0);
        IERC721(m3terNFT).safeTransferFrom(address(this), to, tokenId);
    }

    function onERC721Received(address operator, address, uint256 tokenId, bytes calldata) external returns (bytes4) {
        require(msg.sender == m3terNFT, "Invalid NFT contract");

        _depositNFT(tokenId, operator);

        return IERC721Receiver.onERC721Received.selector;
    }

    function _depositNFT(uint256 tokenId, address from) internal {
        m3terToPowerAgreement[tokenId] = true;
        m3terToOwner[tokenId] = from;

        IERC721(m3terNFT).safeTransferFrom(from, address(this), tokenId);
    }
}
