pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract GatekeeperOneSolution {
    function solve(address _challenge, bytes8 _gateKey) external {
        GatekeeperOne challenge = GatekeeperOne(_challenge);
        bool res = challenge.enter(_gateKey);

        require(res, "did not solve");
    }
}

// Thoughts
//
// Bytes20 = 8 * 20 => 160 bits = 40 hex
// Bytes8 = 8 * 8 => 64 bits = 16 hex
// uint16 = 16 bits = 4 hex
// uint32 = 32 bits = 8 hex
// uint64 = 64 bits = 16 hex
//
// _gateKey = 16 hex, but only right 8 hex is used
// 
//
// require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
// - 9th - 12th hex must be 0
//
// require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
// - First 8 hex cannot be 0s
//
// require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
// - LHS = 0000{RHS}
// - RHS = last 4 hex character of the player