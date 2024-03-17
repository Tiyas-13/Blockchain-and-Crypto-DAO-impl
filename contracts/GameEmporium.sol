// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";

contract GameEmporium {

    // Declare state variables of the contract
    address public owner;
    address public tokenAddress;
    mapping(address => mapping(string => uint)) public inventory;
    uint256 constant DECIMALS = 4;
    uint256 constant WEI = 18;

    // Define prices for each indoor game
    uint constant public poolTablePrice = 1; 
    uint constant public tableTennisPrice = 2;
    uint constant public foosBallTablePrice = 3; 

    // When 'GameEmporium' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. initialize the inventory
    constructor() {
        owner = msg.sender;
        setInventory(address(this), "Pool Table", 10); // Initial quantity for each game
        setInventory(address(this), "Table Tennis Table", 10); 
        setInventory(address(this), "Foosball Table", 10); 
    }

    function setInventory(address _address, string memory _item, uint _quantity) public {
        inventory[_address][_item] = _quantity;
    }

    function getInventory(address _address, string memory _item) public view returns (uint) {
        return inventory[_address][_item];
    }

    function getPriceOf(string memory item) pure public returns (uint) {
        uint256 price;
        if (Strings.equal(item, "Pool Table")) {
            price = poolTablePrice;
        } else if (Strings.equal(item,"Table Tennis Table")) {
            price = tableTennisPrice;
        } else if (Strings.equal(item,"Foosball Table")) {
            price = foosBallTablePrice;
        } else {
            price = 0;
        }
        return price;
    }

    // Allow anyone to purchase a game
    function purchase(string memory item) public payable {
        uint256 price = getPriceOf(item);
        if(price == 0 ) {
            revert("Invalid item selected");
        }
        require(msg.value >= price * (10**(WEI-DECIMALS)), "Insufficient balance to purchase this item");
        require(inventory[address(this)][item] > 0, "Sorry, this item is out of stock");
        inventory[address(this)][item]--;
        inventory[msg.sender][item]++;
    }
}