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
    }

    // events
    event CampaignCreated(
        address indexed creator,
        uint256 goal,
        uint256 deadline
    );
}
