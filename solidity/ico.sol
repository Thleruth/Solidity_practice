pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public pricePerUnit;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReachedFlag = false;
    bool crowdsaleClosedFlag = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    // goold old constructor
    function Crowdsale (
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        pricePerUnit = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    // default (without name) function run when somebody send  to the contract
    function() payable public {
        require(!crowdsaleClosedFlag);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / pricePerUnit);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { 
        if (now >= deadline) _; 
    }

    // check if money or time goal is reached
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReachedFlag = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosedFlag = true;
    }

    // check if goal is reached, if so, let people get token, if not return money raised
    // using modifier to make sure can only be called post deadline
    function safeWithdrawal() afterDeadline public {
        
        // goal not reached
        if (!fundingGoalReachedFlag) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    // could also be 0 since amount is uint
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReachedFlag && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReachedFlag = false;
            }
        }
    }
}
