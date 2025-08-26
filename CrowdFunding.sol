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
    );

    // Modifiers
    modifier ownerCheck() {
        require(
            msg.sender != compaign.creator,
            "creator has no rights to contribute in compaign"
        );
        _;
    }
    modifier stateCheck() {
        require(
            compaign.state == State.Funding,
            "compaign is not under the state FUNDING"
        );
        _;
    }
    modifier deadlineCheck() {
        require(block.timestamp < compaign.deadline, "deadline missed!");
        _;
    }

    // Contribute Anyone
    function contribute() public {}
}
