[collatz-puzzle](https://quillctf.super.site/challenges/quillctf-challenges/collatz-puzzle)

Need to construct a low-size assembly version of the collatz iteration:
```
function collatzIteration(uint256 n) public pure override returns (uint256) {
    if (n % 2 == 0) {
      return n / 2;
    } else {
      return 3 * n + 1;
    }
  }
```

Instead of having a smart contract with actual functions, we can have a bytecode that only does collatzIteration, for anything that would happen

# Runtime bytecode
## Load n from calldata
---
QuillCTF contract is going to call collatzIteration() on our contract, so the first 4 bytes will be the function signature. Loading n requires the next 32 bytes
* 000 PUSH1 (0x60) 0x20 // stack = (0x20)
* 002 PUSH1 (0x60) 0x80 // stack = (0x20, 0x80)
* 004 PUSH1 (0x60) 0x04 // stack = (0x20, 0x80, 0x04)
* 006 CALLDATALOAD (0x35) // stack = (0x20, 0x80, n)
* 007 PUSH1 (0x60) 0x01 // stack = (0x20, 0x80, n, 0x01)

## Compute n % 2
---
* 009 PUSH1 (0x60) 0x02 // stack = (0x20, 0x80, n, 0x01, 0x02)
* 011 DUP3 (0x82) // stack = (0x20, 0x80, n, 0x01, 0x02, n)
* 012 MOD (0x06) // stack = (0x20, 0x80, n, 0x01, n % 2)

## Push instruction 20, to jump there if n % 2 == 0
---
* 013 PUSH1 (0x60) 0x14 // stack = (0x20, 0x80, n, 0x01, n % 2, 0x14)

## Jump to instruction 20 if n % 2 == 1, else keep going
---
* 015 JUMPI (0x57) // stack = (0x20, 0x80, n, 0x01)

## Compute n / 2
---
* 016 SHR (0x1C) // stack = (0x20, 0x80, n / 2)

## Return result
---
* 017 DUP2 (0x81) // stack = (0x20, 0x80, n / 2, 0x80)
* 018 MSTORE (0x52) // memory[0x80:0x80+0x20] = (n * 3 + 1) or n / 2. stack = (0x20, 0x80)
* 019 RETURN (0xF3) // returns memory[0x80:0x80+0x20] == RESULT

## Computation if n % 2 == 1
---
* 020 JUMPDEST (0x5B) // stack = (0x20, 0x80, n, 0x01)
* 021 SWAP1 (0x90) // stack = (0x20, 0x80, 0x01, n)

## Compute n * 3 + 1
---
* 022 PUSH1 (0x60) 0x03 // stack = (0x20, 0x80, 0x01, n, 0x03)
* 024 MUL (0x02) // stack = (0x20, 0x80, 0x01, n * 3)
* 025 ADD (0x01) // stack = (0x20, 0x80, n * 3 + 1)

## Return result
---
* 026 DUP2 (0x81) // stack = (0x20, 0x80, n / 2, 0x80)
* 027 MSTORE (0x52) // memory[0x80:0x80+0x20] = (n * 3 + 1) or n / 2. stack = (0x20, 0x80)
* 028 RETURN (0xF3) // returns memory[0x80:0x80+0x20] == RESULT

All the above in bytecode would be:
602060806004356001600282066014571C8152F35B90600302018152F3, of length 29

# Initialization bytecode
---
should copy contract runtime bytecode to memory and return it from transaction:
* PUSH1 (0x60) 0x1D // stack = (0x1D = 29 = length of runtime bytecode) => 2 opcodes
* PUSH1 (0x60) 0x0C // stack = (0x1D, 0x0C) => 2 opcodes. Initialization bytecode would be 12 bytes, so we need to start copying from 13th byte onward (that's why 0x0C)
* PUSH1 (0x60) 0x00 // stack = (0x1D, 0x0C, 0x00) => 2 opcodes
* CODECOPY (0x39) // stack = () => 1 opcode
* PUSH1 (0x60) 0x1D // stack = (0x1D) => 2 opcodes
* PUSH1 (0x60) 0x00 // stack = (0x1D, 0x00) => 2 opcodes
* RETURN (0xF3) => 1 opcode
* Translated to bytecode, it would be 0x601D600C600039601D6000F3

Final bytecode would be:
0x601D600C600039601D6000F3602060806004356001600282066014571C8152F35B90600302018152F3


Deployed contract with above bytecode at address 0x11B757911624C12b57D799EC4306Af87fd727802

Tested that one collatz iteration works using the below code:
```
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface ICollatz {
  function collatzIteration(uint256 n) external pure returns (uint256);
}

contract CollatzPuzzleSolver {
   ICollatz private constant BYTECODE_ADDRESS = ICollatz(0x11B757911624C12b57D799EC4306Af87fd727802);

   function solver(uint256 n) external pure returns (uint256) {
       return BYTECODE_ADDRESS.collatzIteration(n);
   }
}
```