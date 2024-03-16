// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/// @title Simple DAO smart contract.

import "./VoteToken.sol";
import "./GameEmporium.sol";

contract ArcadeDAO {

    GameEmporium gameEmporium;
    address public GameEmporiumAddress;
    
    uint public voteEndTime;
    uint public DAObalance;

    uint256 constant DECIMALS = 4;
    
    // proposal decision of voters 
    uint public decision;

    mapping(uint => string) public decisionMap;

    // default set as false 
    // makes sure votes are counted before ending vote
    bool public ended;
    Votereum public voteTokens;
    
    struct Voter {
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        string name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    // address of the person who set up the vote 
    address public chairperson;

    mapping(address => Voter) public voters;

    // ["Pool Table", "Table Tennis Table", "Foosball Table"]
    Proposal[] public proposals;

    //error handlers
    /// The vote has already ended.
    error voteAlreadyEnded();
    /// The auction has not ended yet.
    error voteNotYetEnded();

    constructor(
        address _GameEmporiumAddress,
        uint _voteTime,
        string[] memory proposalNames,
        address _tokenAddress
    ) {
        GameEmporiumAddress = _GameEmporiumAddress;
        gameEmporium = GameEmporium(GameEmporiumAddress);
        chairperson = msg.sender;
        voteEndTime = block.timestamp + _voteTime;
        voteTokens = Votereum(_tokenAddress);

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
        decisionMap[0] = "Pool Table";
        decisionMap[1] = "Table Tennis Table";
        decisionMap[2] = "Foosball Table";
    }


    function DepositEth() public payable {
        if (block.timestamp > voteEndTime) {
            revert voteAlreadyEnded();
        }
        uint256 voterWeight = msg.value * (10**DECIMALS);
        require(voteTokens.approve(address(this), voterWeight), "Approve failed");
        require(voteTokens.transferFrom(address(this), msg.sender, voterWeight), "Transfer failed");
        DAObalance = address(this).balance;
    }


    // proposals are in format 0,1,2,...
    function vote(uint proposal) public {
        require(block.timestamp < voteEndTime, "Voting period has ended");
        Voter storage sender = voters[msg.sender];
        // require(voteTokens.balanceOf(msg.sender)>0, "Has no right to vote");
        require(!sender.voted, "Sender already voted.");

        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += 1;
        //proposals[proposal].voteCount += voteTokens.balanceOf(msg.sender);
    }


    // winningProposal must be executed before EndVote
    function countVote() public returns (uint winningProposal_) {
        require(block.timestamp > voteEndTime, "Vote not yet ended.");
        uint winningVoteCount = 0;

        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
                
                decision = winningProposal_;
                ended = true;
            }
        }
    }


    function EndVote() public {
        uint256 price = (gameEmporium.getPriceOf(decisionMap[decision]) * (10**(voteTokens.decimals() - DECIMALS)));
        
        require(block.timestamp > voteEndTime,"Vote not yet ended.");
        require(ended == true,"Must count vote first");  
        require(DAObalance >= price,"Not enough balance in DAO required to buy the voted item");

        if (DAObalance < price) revert();
            (bool success, ) = address(GameEmporiumAddress).call{value: price}(abi.encodeWithSignature("purchase(string)", decisionMap[decision]));
            require(success, "Failed to execute purchase transaction.");
            
        DAObalance = address(this).balance;
    }


    function checkItemBalance(string memory _item) public view returns (uint) {
        return gameEmporium.getInventory(address(this), _item);
    }

}