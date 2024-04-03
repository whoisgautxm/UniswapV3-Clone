pragma solidity ^0.8.20;

import {ERC20} from '../lib/solmate/src/tokens/ERC20.sol';

contract ERC20Mintable is ERC20{
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) ERC20(name, symbol,decimals){}
    function mint (address to, uint256 amount) external {
        _mint(to, amount);
    }
}