// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PowerAggreements is ERC721, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC721("Power Aggrements", "PAs") {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    // mapping for m3ter token ID to Power aggrement token id check
    mapping(uint256 => bool) public m3terToPowerAgreement;

    function createPowerAgreement(address to, uint256 m3terTokenId) external onlyRole(MINTER_ROLE) {
        require(m3terToPowerAgreement[m3terTokenId] == false, "PowerAggreements: Agreement already exists");

        // Mint the Power Agreement token
        _mint(to, m3terTokenId);

        // Map the m3ter token ID to the Power Agreement token ID
        m3terToPowerAgreement[m3terTokenId] = true;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function grantMinter(address account) external onlyRole(ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
    }

    function revokeMinter(address account) external onlyRole(ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
    }
}
