pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../../src/weth-10/weth-10.sol";
import "../../src/weth-10/flash-borrower.sol";

contract Weth10Test is Test {
    WETH10 public weth;
    FlashBorrower public flashBorrower;

    address hacker;

    function setUp() public {
        weth = new WETH10();
        flashBorrower = new FlashBorrower();
        hacker = makeAddr("hacker");

        vm.deal(address(weth), 10 ether);
        vm.deal(address(hacker), 1 ether);
    }

    function testHack() public {
        assertEq(
            address(weth).balance,
            10 ether,
            "weth contract should have 10 ether"
        );

        vm.startPrank(hacker);

        // flashBorrower.requestFlashLoan(address(weth), 10 ether);
        // weth.withdraw(10 ether);
        console.log(weth.balanceOf(hacker));
        console.log(weth.balanceOf(address(weth)));

        vm.stopPrank();
        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(hacker.balance, 11 ether, "player should end with 11 ether");
    }
}
