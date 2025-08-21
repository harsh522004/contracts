// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address owner;
    uint256 private counter;

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
    }

    modifier ownerGuard() {
        require(msg.sender == owner, "Only Onwer can create new proposals");
        _;
    }

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

    function Vote(uint8 choice) external {
        Proposal storage proposal = proposal_history[counter];

        if (proposal.is_active) {
            if (choice == 1) {
                proposal.approve += 1;
                ChagneTheState(proposal);
            } else if (choice == 2) {
                proposal.reject += 1;
                ChagneTheState(proposal);
            } else if (choice == 0) {
                proposal.pass += 1;
                ChagneTheState(proposal);
            }
        }
    }

    // Make Proposal Active - InActive

    function ChagneTheState(Proposal memory proposal) internal pure {
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
        if (total_vote >= proposal.total_vote_to_end) {
            proposal.is_active = false;
        }
    }
}
