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
            proposal_history[counter].is_active,
            "The proposal is not active"
        );
        _;
    }
    modifier canUserVote() {
        require(!votedOrNot(msg.sender), "Address has already voted");
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
        string calldata description,
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

    function Vote(uint8 choice) external active canUserVote {
        Proposal storage proposal = proposal_history[counter];

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = CalculateState(proposal);
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = CalculateState(proposal);
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = CalculateState(proposal);
        }

        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
        if (total_vote >= proposal.total_vote_to_end) {
            proposal.is_active = false;
            delete voted_addresses;
            voted_addresses.push(owner);
        }
    }

    // Make Proposal Active - InActive

    function CalculateState(
        Proposal storage proposal
    ) private view returns (bool) {
        bool isSucceed = (proposal.approve > (proposal.reject * 2));
        return isSucceed;
    }

    // confirm that address already voted or not

    function votedOrNot(address add) private view returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == add) return true;
        }
        return false;
    }

    function getCurrentProposal() external view returns (Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(
        uint256 number
    ) external view returns (Proposal memory) {
        return proposal_history[number];
    }

    function getCurrentStatus() external view returns (bool) {
        return proposal_history[counter].current_state;
    }
}
