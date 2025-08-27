// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./CrowdFunding.sol";

contract CampaignFactory {
    
    address[] private  compaigns; // List of deployed Campaign contracts
    mapping (address => address[]) compaignsOf;

    event CompaignCreated(address indexed compaign, address indexed creator , uint256 goal, uint256 deadline);

    // create compaigns
    function createCampaign(uint256 goal,uint256 durationSeconds) public  {
        CrowdFunding newCrowdFunding = new CrowdFunding(msg.sender , goal, durationSeconds);
        compaigns.push(address(newCrowdFunding)); // add into List of deployed contracts
        compaignsOf[msg.sender].push(address(newCrowdFunding)); // add into mapping of ownership
        emit CompaignCreated(address(newCrowdFunding), msg.sender, goal, block.timestamp + durationSeconds); // emit the event
    }

    function getAllCampaigns() public view returns (address[] memory) {
        return compaigns;
    }

    function getCompaignsOf(address creator) public view returns (address[] memory){
        return compaignsOf[creator];
    }

    function compaignsCount() public view returns (uint256) {
        return compaigns.length;
    }
}