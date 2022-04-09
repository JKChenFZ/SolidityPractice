pragma solidity ^0.6.2;

interface IName {
    function name() external view returns (bytes32);
}

contract FuzzyIdentityChallenge {
    bool public isComplete;

    function authenticate() public {
        require(isSmarx(msg.sender));
        require(isBadCode(msg.sender));

        isComplete = true;
    }

    function isSmarx(address addr) internal view returns (bool) {
        return IName(addr).name() == bytes32("smarx");
    }

    function isBadCode(address _addr) internal pure returns (bool) {
        bytes20 addr = bytes20(_addr);
        bytes20 id = hex"000000000000000000000000000000000badc0de";
        bytes20 mask = hex"000000000000000000000000000000000fffffff";

        for (uint256 i = 0; i < 34; i++) {
            if (addr & mask == id) {
                return true;
            }
            mask <<= 4;
            id <<= 4;
        }

        return false;
    }
}

contract FuzzyIdentitySolution {
    function solve(address _challengeAddress) public {
        FuzzyIdentityChallenge challenge = FuzzyIdentityChallenge(_challengeAddress);
        challenge.authenticate();

        require(challenge.isComplete());
    }

    function name() external pure returns (bytes32) {
        return bytes32("smarx");
    }
}

contract FuzzyIdentityDeployer {
    FuzzyIdentitySolution public solution;
    function solve(address _challengeAddress) public {
        solution.solve(_challengeAddress);
    }

    function deploy(bytes32 _salt) public returns (address) {
        solution = new FuzzyIdentitySolution{salt: _salt}();
    }

    function getAddress(bytes memory bytecode, uint256 _salt) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }
}