// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TLNTokenContract is ERC20, Pausable, Ownable {
    
    /**
     * @dev Constructor that initializes the token with a name, symbol, and total supply.
     *      The contract deployer is set as the owner and receives the initial supply.
     * @param name The name of the ERC20 token.
     * @param symbol The symbol of the ERC20 token.
     * @param tokenSupply Total supply of the token (before applying decimals).
     */
    constructor(string memory name, string memory symbol, uint256 tokenSupply) 
        ERC20(name, symbol) 
        Ownable(msg.sender) 
    {
        _mint(msg.sender, tokenSupply * 10 ** decimals());
    }

    /**
     * @dev Allows the owner to pause all token transfers.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Allows the owner to unpause token transfer.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    function _update(address from, address to, uint256 value) 
        internal 
        virtual 
        override 
        whenNotPaused 
    {
        super._update(from, to, value);
    }
}
