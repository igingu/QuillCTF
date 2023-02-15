pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {D31eg4t3, D31eg4t3Hack} from "../../src/d31eg4t3/d31eg4t3.sol";

contract D31eg4t3Test is Test {
    D31eg4t3 public delegate;
    D31eg4t3Hack public delegateHack;

    address hacker;

    function setUp() public {
        delegate = new D31eg4t3();
        delegateHack = new D31eg4t3Hack();
        hacker = makeAddr("hacker");
    }

    function testD31eg4t3Hack() public {
        assertTrue(delegate.owner() != hacker);

        vm.startPrank(hacker, hacker);

        delegateHack.hackd31eg4t3(delegate);
        delegate.hacked();

        vm.stopPrank();

        assertEq(delegate.owner(), hacker);
        assertTrue(delegate.canYouHackMe(hacker));
    }
}
