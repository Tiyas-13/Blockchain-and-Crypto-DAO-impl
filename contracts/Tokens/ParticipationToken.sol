// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ParticipationToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor(address initialOwner)
        ERC20("ParticipationToken", "PTK")
        Ownable(initialOwner)
        ERC20Permit("ParticipationToken")
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount * (10 ** uint256(decimals())));
    }

    function sendParticipationToken(address from, address to, uint256 amount) public returns (bool){
        approve(from, amount * (10 ** uint256(decimals())));
        return transferFrom(from, to, amount * (10 ** uint256(decimals())));
    }

    function transferParticipationToken(address from, address to, uint256 amount, address contractAddress) public virtual returns (bool){
        _spendAllowance(contractAddress, from, amount * (10 ** uint256(decimals())));
        _transfer(from, to, amount * (10 ** uint256(decimals())));
        return true;
    }
}