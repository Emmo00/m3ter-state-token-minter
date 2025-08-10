// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/L1MinterAndBridger.sol";
import "../src/interfaces/IL1Token.sol";
import "../src/interfaces/IL1StandardBridge.sol";
import "../src/interfaces/IRollup.sol";
import "../src/PowerAggreements.sol";

contract MockPowerAggreements is PowerAggreements {
    constructor(address nft) PowerAggreements(nft) {}

    function setAgreement(uint256 tokenId, bool exists) external {
        m3terToPowerAgreement[tokenId] = exists;
    }

    function setOwner(uint256 tokenId, address owner) external {
        m3terToOwner[tokenId] = owner;
    }
}

contract MockRollup is IRollup {
    mapping(uint256 => bytes6) public accounts;

    function setAccount(uint256 tokenId, bytes6 balance) external {
        accounts[tokenId] = balance;
    }

    function account(uint256 tokenId) external view override returns (bytes6) {
        return accounts[tokenId];
    }
}

contract MockL1Token is IL1Token {
    uint8 public decimalsVal = 18;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    function setDecimals(uint8 d) external {
        decimalsVal = d;
    }

    function decimals() external view override returns (uint8) {
        return decimalsVal;
    }

    function mint(address to, uint256 amount) external override {
        balances[to] += amount;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }
}

contract MockL1StandardBridge is IL1StandardBridge {
    struct Deposit {
        address l1Token;
        address l2Token;
        address to;
        uint256 amount;
        uint32 l2Gas;
        bytes data;
    }

    Deposit public lastDeposit;

    function depositERC20To(
        address l1Token,
        address l2Token,
        address to,
        uint256 amount,
        uint32 l2Gas,
        bytes calldata data
    ) external override {
        lastDeposit = Deposit(l1Token, l2Token, to, amount, l2Gas, data);
    }
}

contract L1MinterAndBridgerTest is Test {
    L1MinterAndBridger public minter;
    MockPowerAggreements public agreements;
    MockRollup public rollup;
    MockL1Token public l1Token;
    MockL1StandardBridge public bridge;

    address public l2Token = address(0xBEEF);
    address public user = address(0xCAFE);

    function setUp() public {
        agreements = new MockPowerAggreements(address(0xBEFE));
        rollup = new MockRollup();
        l1Token = new MockL1Token();
        bridge = new MockL1StandardBridge();

        minter =
            new L1MinterAndBridger(address(agreements), address(rollup), address(l1Token), l2Token, address(bridge));
    }

    // --- Revert Tests ---
    function test_RevertIf_InvalidM3terTokenId() public {
        agreements.setAgreement(1, false);

        vm.expectRevert("L1MinterAndBridger: Invalid m3ter token ID");
        minter.mintAndBridge(1, 100_000, "");
    }

    function test_RevertIf_ZeroCumulativeBalance() public {
        agreements.setAgreement(1, true);
        rollup.setAccount(1, bytes6(0));

        vm.expectRevert("L1MinterAndBridger: Insufficient balance");
        minter.mintAndBridge(1, 100_000, "");
    }

    function test_RevertIf_NoDeltaSinceLastMint() public {
        agreements.setAgreement(1, true);
        rollup.setAccount(1, bytes6(uint48(100)));

        // set minted to equal cumulative balance using vm.store
        bytes32 slot = keccak256(abi.encode(1, uint256(0))); // mapping slot is 0
        vm.store(address(minter), slot, bytes32(uint256(100)));

        vm.expectRevert("L1MinterAndBridger: Insufficient balance");
        minter.mintAndBridge(1, 100_000, "");
    }

    // --- Happy Path ---
    function test_MintAndBridge_Success() public {
        uint256 tokenId = 1;
        agreements.setAgreement(tokenId, true);
        agreements.setOwner(tokenId, user);

        uint48 cumulative = 500; // rollup balance
        rollup.setAccount(tokenId, bytes6(cumulative));

        uint8 dec = 18;
        l1Token.setDecimals(dec);

        uint256 expectedAmountRaw = cumulative * (10 ** dec);
        uint256 expectedEncoded = (expectedAmountRaw << 12) | tokenId;

        minter.mintAndBridge(tokenId, 55_000, hex"1234");

        assertEq(l1Token.balances(address(minter)), expectedEncoded, "Minted balance incorrect");
        assertEq(l1Token.allowances(address(minter), address(bridge)), expectedEncoded, "Allowance incorrect");

        (address l1Token_, address l2Token_, address to_, uint256 amount_, uint32 l2Gas_, bytes memory data_) =
            bridge.lastDeposit();

        assertEq(l1Token_, address(l1Token));
        assertEq(l2Token_, l2Token);
        assertEq(to_, user);
        assertEq(amount_, expectedEncoded);
        assertEq(l2Gas_, 55_000);
        assertEq(data_, hex"1234");
    }

    // --- Edge Cases ---
    function test_EncodingWorksWithNon18Decimals() public {
        agreements.setAgreement(2, true);
        agreements.setOwner(2, user);

        rollup.setAccount(2, bytes6(uint48(100)));

        l1Token.setDecimals(6); // non-standard decimals

        uint256 expectedAmountRaw = 100 * (10 ** 6);
        uint256 expectedEncoded = (expectedAmountRaw << 12) | 2;

        minter.mintAndBridge(2, 100, "");

        assertEq(l1Token.balances(address(minter)), expectedEncoded);
    }
}
