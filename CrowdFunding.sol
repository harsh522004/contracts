
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract CrowdFunding {
    // state of Compaign
    enum State {
        Funding,
        Successful,
        Failed,
        Withdrawn
    }

    // Data structure of Compaign
    struct Compaign {
        address creator;
        uint256 goal;
        uint256 deadline;
        uint256 totalRaised;
        State state;
        mapping(address => uint256) contribution;
    }

    // Data state
    Compaign compaign;
    bool isWithdrawn = false;

    // Constructor
    constructor(uint256 goal, uint256 durationSeconds) {
        compaign.creator = msg.sender;
        compaign.goal = goal;
        compaign.deadline = block.timestamp + durationSeconds;
        compaign.totalRaised = 0;
        compaign.state = State.Funding;

        emit CampaignCreated(compaign.creator, goal, compaign.deadline);
    }

    // events
    event CampaignCreated(
        address indexed creator,
        uint256 goal,
        uint256 deadline
    ); // when compaign created
    event Contributed(address indexed contributor,uint256 amount , uint256 newTotal,bool IsSucess); // when someone contribute
    event Withdrawn(address indexed creator, uint256 amount);
    event Refund(address indexed banker , uint256 amount);


    // Contribute Anyone
    function contribute() public  payable {
        require(
            msg.sender != compaign.creator,
            "creator has no rights to contribute in compaign"
        );
        require(
            compaign.state == State.Funding,
            "compaign is not under the state FUNDING"
        );
         require(block.timestamp < compaign.deadline, "deadline missed!");
         require(msg.value > 0 , "Amount of contibution is zero!");
        compaign.contribution[msg.sender] += msg.value;
        compaign.totalRaised += msg.value;
        bool isSuccess = compaign.totalRaised >= compaign.goal;
        if(isSuccess) compaign.state = State.Successful;
        emit Contributed(msg.sender, msg.value, compaign.totalRaised,isSuccess); // emit the event
    }

    // Finalize the state of contract
    function finalize() public  {
        require(block.timestamp > compaign.deadline , "compaign is still in progress!");
        if(compaign.totalRaised >= compaign.goal) compaign.state = State.Successful;
        else compaign.state = State.Failed;
    }

    // Withdrawal function
    function withdraw()public payable    {
        require(
            msg.sender == compaign.creator,
            "only owner has right to this action!"
        );
        require(
            compaign.state == State.Successful,
            "compaign is not yet successful"
        );
        require(compaign.totalRaised > 0 && !isWithdrawn , "Withdrawn is not possible!");
        (bool success , ) =  msg.sender.call{value : compaign.totalRaised}("");
        require(success , "ETH withdrawal failed!");
        emit Withdrawn(msg.sender, compaign.totalRaised);
    }

    // Refund
    function refund() public payable {
        require(compaign.state == State.Failed , "compaign state is not fail");
        require(compaign.contribution[msg.sender] > 0, "you are not contributor for compaign");

        uint256 amount = compaign.contribution[msg.sender];
        compaign.contribution[msg.sender] = 0;
        (bool success , ) =  msg.sender.call{value : amount}("");
        require(success , "Error occured!");
        emit Refund(msg.sender, amount);

    }
}
