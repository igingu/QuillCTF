## [true-xor](https://quillctf.super.site/challenges/quillctf-challenges/true-xor)

Context: 
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TrueXOR {
  function callMe(address target) external view returns (bool) {
    bool p = IBoolGiver(target).giveBool();
    bool q = IBoolGiver(target).giveBool();
    require((p && q) != (p || q), "bad bools");
    require(msg.sender == tx.origin, "bad sender");
    return true;
  }
}

interface IBoolGiver {
  function giveBool() external view returns (bool);
}
```

Initial Idea: 
* contract must be called by EOA, so that ```require(msg.sender == tx.origin, "bad sender");``` doesn't revert
* what about ```require((p && q) != (p || q), "bad bools");```
* my TrueXorSolver contract can not change state variables upon sequent calls (since it's view), so we need to somehow return different flags
* ```return gasleft() % 2 == 0```
* unfortunately this would always return the same flag, so I had to introduce something with an odd amount of gas consumption, so the gasleft() of two subsequent calls would have different parity
* calldatacopy consumes 3, and calldatasize 2, so ```calldatacopy(0, 0, calldatasize())``` gives odd number of gas units consumed
```
contract TrueXORSolver is IBoolGiver {
    function giveBool() external view override returns (bool) {
        bool flag = gasleft() % 2 == 0;
        assembly {
            calldatacopy(0, 0, calldatasize())
        }
        return flag;
    }
}
```
* deployed TrueXORSolver with Remix, took note of address and called TrueXor.callMe(TrueXORSolver address)
* [TrueXOR on Goerli](https://goerli.etherscan.io/address/0x1544ee89de52eaab4799f7788d1a1edd0752e24e)
* [TrueXOR solver on Goerli](https://goerli.etherscan.io/address/0x384387621a6243BF730A9bfB4e73b7D117BE6A08)
