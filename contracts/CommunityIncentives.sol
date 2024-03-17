// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./GymMembershipToken.sol";

contract CommunityIncentives {

    // Declare state variables of the contract
    address public owner;
    GymMembershipToken public gymMembershipToken;
    mapping(address => mapping(string => uint)) public balance;
    mapping(string => uint) public minParticipationVotes;

    constructor(
        address _GymMembershipTokenAddress
    ) {
        owner = msg.sender;
        gymMembershipToken = GymMembershipToken(_GymMembershipTokenAddress);
        setInventory(address(this), "GymMembership", 10);
        setMinParticipationVotesRequired("GymMembership", 1);
    }

    function setInventory(address _address, string memory _item, uint _quantity) public {
        balance[_address][_item] = _quantity;
    }

    function getInventory(address _address, string memory _item) public view returns (uint) {
        return balance[_address][_item];
    }

    function setMinParticipationVotesRequired(string memory _item, uint _quantity) public {
        minParticipationVotes[_item] = _quantity;
    }

    function getMinParticipationVotesRequired(string memory _item) public view returns (uint) {
       return minParticipationVotes[_item];
    }

    // Allow anyone to purchase a game
    function getIncentive(string memory incentive) public {
        if(Strings.equal(incentive, "GymMembership")) {
            gymMembershipToken.transferGymMembershipTokenTo(address(this), msg.sender, 1);
        } else {
            revert("Invalid choice");
        }
        balance[address(this)][incentive]--;
        balance[msg.sender][incentive]++;
    }
}
