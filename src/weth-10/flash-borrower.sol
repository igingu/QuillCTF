// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Address} from "openzeppelin/contracts/utils/Address.sol";

import "forge-std/console.sol";

interface IFlashLender {
    function execute(
        address receiver,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract FlashBorrower {
    function onFlashLoan(bytes calldata) external payable {
        Address.functionCallWithValue(
            msg.sender,
            abi.encodeWithSignature("deposit()"),
            msg.value
        );
    }

    function requestFlashLoan(address flashLender, uint256 amount) external {
        (IFlashLender(flashLender)).execute(
            address(this),
            amount,
            abi.encodeWithSignature("onFlashLoan(bytes)", 0x00)
        );
    }
}
