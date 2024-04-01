// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.20;

interface IUniswapV3MintCallback {
    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1
    ) external;
}