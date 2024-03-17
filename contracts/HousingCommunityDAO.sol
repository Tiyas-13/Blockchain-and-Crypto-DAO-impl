// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/// @title Simple DAO smart contract.

import "./Tokens/VoteToken.sol";
import "./GameEmporium.sol";
import "./Tokens/ParticipationToken.sol";
import "./CommunityIncentives.sol";

contract HousingCommunityDAO {

    GameEmporium gameEmporium;
    CommunityIncentives communityIncentives;

    address public GameEmporiumAddress;
    address public CommunityIncentivesAddress;

    // Voting parameters
    uint public voteEndTime; // Timestamp marking the end of the voting period
    uint public DAObalance; // Balance of the DAO contract
    uint public voteDuration; // Duration of the voting period

    uint256 constant DECIMALS = 4;
    uint256 constant WEI = 18;
    
    // proposal decision of voters 
    uint public decision;

    // Mapping of proposal index to proposal name
    mapping(uint => string) public decisionMap;

    // Voting status: default set as false 
    // makes sure votes are counted before ending vote
    bool public hasVoteStarted; // Flag indicating whether the voting has started
    bool public ended; // Flag indicating whether the voting has ended

    // Token contracts
    VoteToken public voteTokens;
    ParticipationToken public participationToken;
    
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

    // Mapping of addresses to Voter
    mapping(address => Voter) public voters;

    // Array holding the proposals for voting
    // Proposals: ["Pool Table", "Table Tennis Table", "Foosball Table"]
    Proposal[] public proposals;

    //error handlers
    error voteAlreadyEnded();  // Error indicating that the vote has already ended
    error voteNotYetEnded(); // Error indicating that the vote has not yet ended

    constructor(
        address _GameEmporiumAddress,
        address _CommunityIncentivesAddress,
        uint _voteTime,
        string[] memory proposalNames,
        address _VoteTokenAddress,
        address _ParticipationTokenAddress
    ) { 
        // Initialize external contract references
        GameEmporiumAddress = _GameEmporiumAddress;
        gameEmporium = GameEmporium(GameEmporiumAddress);
        CommunityIncentivesAddress = _CommunityIncentivesAddress;
        communityIncentives = CommunityIncentives(CommunityIncentivesAddress);

        // Initialize chairperson and voting parameters
        chairperson = msg.sender;
        voteDuration = _voteTime;
        
        // Initialize token/NFT contracts
        voteTokens = VoteToken(_VoteTokenAddress);
        participationToken = ParticipationToken(_ParticipationTokenAddress);

        // Initialize proposals
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }

        // Initialize decision map
        decisionMap[0] = "Pool Table";
        decisionMap[1] = "Table Tennis Table";
        decisionMap[2] = "Foosball Table";
    }


    /**
     * @dev Mint participation tokens.
     * @param amount Amount of tokens to mint.
     */
    function mintParticipationTokens(uint256 amount) public {
        participationToken.mint(address(this), amount);
    }


    /**
     * @dev Mint vote tokens.
     * @param amount Amount of tokens to mint.
     */
    function mintVoteTokens(uint256 amount) public {
        voteTokens.mint(address(this), amount);
    }


    /**
     * @dev Start the voting process. Only chairperson can start the voting
     */
    function startVote() public {
        require(
            msg.sender == chairperson, "Only chairperson can start the voting"
        );
        voteEndTime = block.timestamp + voteDuration;
        hasVoteStarted = true;
    }


    /**
     * @dev Deposit ETH and acquire vote tokens based on amount deposited.
     */
    function DepositEth() public payable {
        require(hasVoteStarted == true, "Vote has not started yet");
        if (block.timestamp > voteEndTime) {
            revert voteAlreadyEnded();
        }
        uint256 voterWeight = msg.value * (10**DECIMALS);
        if(voteTokens.balanceOf(address(this))<voterWeight) {
            mintVoteTokens(100);
        }
        // Transfer vote tokens
        require(voteTokens.approve(address(this), voterWeight), "Approve failed");
        require(voteTokens.transferFrom(address(this), msg.sender, voterWeight), "Transfer failed");
        DAObalance = address(this).balance;
    }


    /**
     * @dev Vote for a proposal. Proposals are in format 0,1,2,...
     * @param proposal Index of the proposal to vote for. 
     */
    function vote(uint proposal) public {
        require(block.timestamp < voteEndTime, "Voting period has ended");
        Voter storage sender = voters[msg.sender];
        require(voteTokens.balanceOf(msg.sender)>0, "Has no right to vote");
        require(!sender.voted, "Sender already voted.");

        sender.voted = true;
        sender.vote = proposal;

        // Increment vote count for proposal chosen by the voter
        proposals[proposal].voteCount += voteTokens.balanceOf(msg.sender);
        if(participationToken.balanceOf(address(this))<1) {
            mintParticipationTokens(100);
        }
        // Give a participationToken to each voter for participation in voting
        participationToken.sendParticipationToken(address(this), msg.sender, 1);
    }


    /**
     * @dev Count votes and determine the winning proposal.
     * @return winningProposal_ Index of the winning proposal.
     */
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


    /**
     * @dev End the voting process and call GameEmporium for purchase.
     */
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


    /**
     * @dev Redeem incentives.
     * @param _incentive Incentive to redeem.
     * @param participant Address of the participant redeeming the incentive.
     */
    function redeemIncentives(string memory _incentive, address participant) public {
        // Get minimum participation token required to redeem incentive
        uint minParticipationVotes = communityIncentives.getMinParticipationVotesRequired(_incentive);
        require(participationToken.balanceOf(participant) >= minParticipationVotes * (10 ** WEI), "Insufficent balance");

        // Use the participation tokens to redeem incentive 
        participationToken.approve(participant, minParticipationVotes * (10 ** WEI));
        participationToken.transferParticipationToken(participant, address(this), minParticipationVotes, address(this));
        communityIncentives.getIncentive(_incentive, participant);
    }


    /**
     * @dev Check the balance of a specific item in the GameEmporium.
     * @param _item Name of the item to check balance for.
     * @return Balance of the item.
     */
    function checkItemBalance(string memory _item) public view returns (uint) {
        return gameEmporium.getInventory(address(this), _item);
    }

}