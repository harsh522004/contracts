// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./CrowdFunding.sol";

contract CampaignFactory {
    
    address[] private  compaigns; // List of deployed Campaign contracts
    mapping (address => address[]) compaignsOf;

    event CompaignCreated(address indexed compaign, uint256 salt , address indexed creator , uint256 goal, uint256 deadline);

    // create compaigns : All Methods are open & Not Payable
    function createCampaign(uint256 goal,uint256 durationSeconds, uint256 salt) public  {
        CrowdFunding newCrowdFunding = new CrowdFunding{salt : bytes32(uint256(salt))}(msg.sender , goal, durationSeconds); // added salt for Predictable Address
        compaigns.push(address(newCrowdFunding)); // add into List of deployed contracts
        compaignsOf[msg.sender].push(address(newCrowdFunding)); // add into mapping of ownership
        emit CompaignCreated(address(newCrowdFunding), salt, msg.sender, goal, block.timestamp + durationSeconds); // emit the event
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

    function getRecent(uint256 n) public view returns (address[] memory) {
        uint arrayLength = compaigns.length;
        uint startIndex = arrayLength - n;
        address[] memory result = new address[](n);
        uint count = 0;
        for (uint i = startIndex; i < arrayLength; i++) 
        {
            result[count] = compaigns[i];
            count++;
        }
        return result;
    }

    function getAddressFromSalt(uint256 salt, address owner, uint256 goal , uint256 durationSeconds) public view returns (address){
        bytes memory bytecode =  abi.encodePacked(type(CrowdFunding).creationCode, abi.encode(owner,goal, durationSeconds));
         bytes32 hash = keccak256(

            abi.encodePacked(

                bytes1(0xff), address(this), bytes32(salt), keccak256(bytecode)
            )

        );
        return address (uint160(uint(hash)));
    }
}