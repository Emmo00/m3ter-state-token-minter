// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @notice Mock of the Rollup contract used for testing — no zk-verifier, blobs stored in mappings.
///         Exposes the same read API (account, nonce, state, stateAddress, latestStateAddress).
contract MockRollup {
    uint256 public chainLength;

    // store blobs per index (mimic SSTORE2 content)
    mapping(uint256 => bytes) internal accountBlobs;
    mapping(uint256 => bytes) internal nonceBlobs;

    /// @notice Emitted when a new state is committed (keeps signature compatible with the real contract)
    event NewState(
        address indexed sender, uint256 indexed index, uint256 anchor, bytes account, bytes nonce, bytes proof
    );

    constructor() {
        // initialize index 0 with empty blobs and emit event like real contract
        accountBlobs[0] = hex"00";
        nonceBlobs[0] = hex"00";
        emit NewState(msg.sender, 0, 0, "", "", "");
    }

    /// @notice Commit a new state. Proof argument ignored (mock).
    function commitState(
        uint256 anchorBlock,
        bytes calldata accountBlob,
        bytes calldata nonceBlob,
        bytes calldata /* proof */
    ) external {
        chainLength++;
        // store blobs at the new chainLength
        accountBlobs[chainLength] = accountBlob;
        nonceBlobs[chainLength] = nonceBlob;

        emit NewState(msg.sender, chainLength, anchorBlock, accountBlob, nonceBlob, "");
    }

    /// @notice Return 6-byte account data for current chain length
    function account(uint256 tokenId) external view returns (bytes6) {
        return state(chainLength, this.account.selector, tokenId);
    }

    /// @notice Return 6-byte nonce data for current chain length
    function nonce(uint256 tokenId) external view returns (bytes6) {
        return state(chainLength, this.nonce.selector, tokenId);
    }

    /// @notice Mimic the real contract's latestStateAddress(selectorSelector: 0 => account, 1 => nonce)
    function latestStateAddress(uint256 io) external view returns (address) {
        return stateAddress(chainLength, io == 0 ? this.account.selector : this.nonce.selector);
    }

    /// @notice Deterministic pseudo-address so callers that expect an address get one.
    ///         This mirrors SSTORE2.predictDeterministicAddress behavior for tests (not exact).
    function stateAddress(uint256 at, bytes4 selector) public pure returns (address) {
        // deterministic pseudo-address derived from selector+index
        return address(uint160(uint256(keccak256(abi.encodePacked(selector, at)))));
    }

    /// @notice Return a 6-byte slice for tokenId from the blob stored at `at` for given selector.
    ///         Layout: tokenId == 0 -> bytes[0..5], else offset = tokenId*6 - 1, read 6 bytes.
    function state(uint256 at, bytes4 selector, uint256 tokenId) public view returns (bytes6) {
        bytes memory blob = selector == this.account.selector ? accountBlobs[at] : nonceBlobs[at];

        if (tokenId == 0) {
            return _read6(blob, 0);
        }
        uint256 index = (tokenId * 6) - 1;
        return _read6(blob, index);
    }

    /// @dev Read 6 bytes out of `b` at `offset`. If out of bounds, returns 0.
    function _read6(bytes memory b, uint256 offset) internal pure returns (bytes6) {
        // fast out-of-bounds check
        if (b.length < offset + 6) return bytes6(0);

        uint48 val = 0;
        for (uint256 i = 0; i < 6; i++) {
            val = (val << 8) | uint48(uint8(b[offset + i]));
        }
        return bytes6(val);
    }

    // helper for tests: allow reading raw blob (not in original interface but useful)
    function rawAccountBlob(uint256 at) external view returns (bytes memory) {
        return accountBlobs[at];
    }

    function rawNonceBlob(uint256 at) external view returns (bytes memory) {
        return nonceBlobs[at];
    }
}
