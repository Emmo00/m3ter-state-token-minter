// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IRollup} from "./interfaces/IRollup.sol";

contract CarbonCredits is ERC721 {
    uint64 public constant BASE = 10e9; // multiplier to convert energy from rollup contract to Mwh
    uint64 public remainderCarbonCredits; // remainder from last mint to carry over

    uint256 private _nextTokenId; // Next token ID to be minted

    address immutable manager; // Address that owns the m3ter NFTs and receives minted Carbon Credits
    address immutable rollup; // Address of the Rollup contract for state management
    address immutable m3terNFT; // Address of the m3ter NFT contract

    mapping(uint256 => uint256) public tokenToCummulativeEnergy;

    constructor(address rollup_, address m3terNFT_) ERC721("CarbonCredits", "CC") {
        manager = msg.sender;
        rollup = rollup_;
        m3terNFT = m3terNFT_;
    }

    function mint(uint256[] calldata tokenIds) external returns (uint256) {
        uint256 totalEnergyConsumedSinceLastMint = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            // check token ownership (must be owned by manager)
            require(IERC721(m3terNFT).ownerOf(tokenId) == manager, "Not the owner of m3ter NFT");

            // get cummulative energy from rollup contract
            uint256 cummulativeEnergy = uint256(uint48(IRollup(rollup).account(tokenId)));

            // get energy consumed since last mint
            uint256 energyConsumed = cummulativeEnergy - tokenToCummulativeEnergy[tokenId];
            tokenToCummulativeEnergy[tokenId] = cummulativeEnergy;

            totalEnergyConsumedSinceLastMint += energyConsumed;
        }

        // total carbon credit units before flooring
        uint256 totalCreditsWithRemainder = (totalEnergyConsumedSinceLastMint * 7) + remainderCarbonCredits;

        // integer credits minted
        uint256 creditsToMint = totalCreditsWithRemainder / (10 * BASE);

        // new remainder
        remainderCarbonCredits = uint64(totalCreditsWithRemainder % (10 * BASE));

        // mint NFTs for creditsToMint
        for (uint256 i = 0; i < creditsToMint; i++) {
            _safeMint(manager, _nextTokenId++);
        }
    }
}
