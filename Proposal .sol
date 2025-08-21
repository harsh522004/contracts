// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    // Data
    address owner;
    uint256 private counter;
    address[] private voted_addresses;

    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state; // pass or fail
        bool is_active; // can vote or not
    }
    mapping(uint256 => Proposal) proposal_history;

    constructor() {
        owner = msg.sender;
        voted_addresses.push(owner);
    }

    // Modifiers

    modifier ownerGuard() {
        require(msg.sender == owner, "Only Onwer can create new proposals");
        _;
    }

    modifier active() {
        require(
            proposal_history[counter].is_active == true,
            "The proposal is not active"
        );
        _;
    }
    modifier canUserVote() {
        require(votedOrNot(msg.sender) == true, "Address has already voted");
        _;
    }

    // Methods

    // Change the Owner

    function setOwner(address new_owner) external ownerGuard {
        owner = new_owner;
    }

    // Create Proposal

    function Create(
        string calldata title,
        string memory description,
        uint256 vote_limit
    ) external ownerGuard {
        counter += 1;
        proposal_history[counter] = Proposal(
            title,
            description,
            0,
            0,
            0,
            vote_limit,
            false,
            true
        );
    }

    // Vote

    function Vote(uint8 choice) external active {
        Proposal storage proposal = proposal_history[counter];

        if (choice == 1) {
            proposal.approve += 1;
            voted_addresses.push(msg.sender);
            ChagneTheState(proposal);
        } else if (choice == 2) {
            proposal.reject += 1;
            ChagneTheState(proposal);
            voted_addresses.push(msg.sender);
        } else if (choice == 0) {
            proposal.pass += 1;
            ChagneTheState(proposal);
            voted_addresses.push(msg.sender);
        }
    }

    // Make Proposal Active - InActive

    function ChagneTheState(Proposal memory proposal) private {
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
        if (total_vote >= proposal.total_vote_to_end) {
            proposal.is_active = false;
            voted_addresses = [owner]; // Rest the array of voted users
        }

        bool isSucceed = (proposal.approve > (proposal.reject * 2));
        proposal.current_state = isSucceed;
    }

    // confirm that address already voted or not

    function votedOrNot(address add) private view returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == add) return true;
        }
        return false;
    }
}
