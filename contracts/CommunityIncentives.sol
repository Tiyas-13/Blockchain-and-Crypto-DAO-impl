// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./NFTs/GymMembershipNFT.sol";
import "./NFTs/PoolAccessNFT.sol";
import "./NFTs/ParkingPassNFT.sol";

contract CommunityIncentives {

    address public owner;

    // Instances of NFT contracts for gym membership, pool access, and parking pass
    GymMembershipNFT public gymMembershipNFT;
    PoolAccessNFT public poolAccessNFT;
    ParkingPassNFT public parkingPassNFT;

    // Mapping to store balances of different incentives for each address
    mapping(address => mapping(string => uint)) public balance;

    // Mapping to store minimum participation votes required for each incentive
    mapping(string => uint) public minParticipationVotes;

    // Mapping to store the token ID of the NFT owned by each participant for each incentive
    mapping(address => mapping(string => uint)) public NFTtokenIdMapping;

    // Counters for token IDs of gym membership, pool access, and parking pass
    uint public gymMembershipTokenCounter;
    uint public poolAccessTokenCounter;
    uint public parkingPassTokenCounter;

    constructor(
        address _GymMembershipNFTAddress,
        address _PoolAccessNFTAddress,
        address _ParkingPassNFTAddress
    ) {
        owner = msg.sender;

        // Initializing instances of NFT contracts
        gymMembershipNFT = GymMembershipNFT(_GymMembershipNFTAddress);
        poolAccessNFT = PoolAccessNFT(_PoolAccessNFTAddress);
        parkingPassNFT = ParkingPassNFT(_ParkingPassNFTAddress);

        // Setting initial inventory for each incentive
        setInventory(address(this), "GymMembership", 10);
        setInventory(address(this), "PoolAccess", 10);
        setInventory(address(this), "ParkingPass", 10);

        // Setting minimum participation votes required for each incentive
        setMinParticipationVotesRequired("GymMembership", 2);
        setMinParticipationVotesRequired("PoolAccess", 1);
        setMinParticipationVotesRequired("ParkingPass", 3);

        // Initializing token counters
        gymMembershipTokenCounter = 0;
        poolAccessTokenCounter = 0;
        parkingPassTokenCounter = 0;
    }

    // Function to set the inventory of an item for a specific address
    function setInventory(address _address, string memory _item, uint _quantity) public {
        balance[_address][_item] = _quantity;
    }

    // Function to get the inventory of an item for a specific address
    function getInventory(address _address, string memory _item) public view returns (uint) {
        return balance[_address][_item];
    }

    // Function to set the minimum participation votes required for an incentive
    function setMinParticipationVotesRequired(string memory _item, uint _quantity) public {
        minParticipationVotes[_item] = _quantity;
    }

    // Function to get the minimum participation votes required for an incentive
    function getMinParticipationVotesRequired(string memory _item) public view returns (uint) {
       return minParticipationVotes[_item];
    }

    // Function to distribute incentives to participants
    function getIncentive(string memory incentive, address participant) public {

        if(Strings.equal(incentive, "GymMembership")) {
            gymMembershipNFT.safeMint(participant);
            NFTtokenIdMapping[participant][incentive] = gymMembershipTokenCounter;
            gymMembershipTokenCounter++;
        } 
        else if (Strings.equal(incentive, "PoolAccess")) {
            poolAccessNFT.safeMint(participant);
            NFTtokenIdMapping[participant][incentive] = poolAccessTokenCounter;
            poolAccessTokenCounter++;
        } 
        else if (Strings.equal(incentive, "ParkingPass")) {
            parkingPassNFT.safeMint(participant);
            NFTtokenIdMapping[participant][incentive] = parkingPassTokenCounter;
            parkingPassTokenCounter++;
        } 
        else {
            revert("Invalid choice");
        }
        // Updating balances of the contract and the participant
        balance[address(this)][incentive]--;
        balance[msg.sender][incentive]++;
    }

    // Function to get the token ID of the NFT owned by a participant for a specific incentive
    function getTokenID(address participant, string memory incentive) public view returns(uint) {
        return NFTtokenIdMapping[participant][incentive];
    }
}