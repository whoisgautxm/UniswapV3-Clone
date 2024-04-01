pragma solidity ^0.8.20;

import {Tick} from "../lib/Tick.sol";
import {Position} from "../lib/Position.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IUniswapV3MintCallback} from "./interfaces/IUniswapV3MintCallback.sol";

contract UniswapV3Pool {
    event Mint(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    //Pool tokens , immutable

    address public immutable token0;
    address public immutable token1;

    // Packing variabbles that are read together
    struct Slot0 {
        //Current sqrt(p)
        uint160 sqrtPriceX96;
        //Tick
        int24 tick;
    }
    Slot0 public slot0;

    //Amount of liquidity , L
    uint128 public liquidity;

    //Tick info
    mapping(int24 => Tick.Info) public ticks;
    mapping(bytes32 => Position.Info) public positions;

    //Constructor
    constructor(
        address _token0,
        address _token1,
        uint160 _sqrtPriceX96,
        int24 _tick
    ) {
        token0 = _token0;
        token1 = _token1;
        slot0 = Slot0({sqrtPriceX96: _sqrtPriceX96, tick: _tick});
    }

    function mint(
        address owner,
        int24 lowerTick,
        int24 uppperTick,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1) {
        if (
            lowerTick >= uppperTick ||
            lowerTick < MIN_TICK ||
            uppperTick > MAX_TICK
        ) revert("UniswapV3Pool: INVALID_RANGE");
        if (amount == 0) revert("UniswapV3Pool: INSUFFICIENT_LIQUIDITY_MINTED");

        Tick.update(ticks, lowerTick, amount);
        Tick.update(ticks, uppperTick, amount);
        Position.Info storage position = Position.get(
            positions,
            owner,
            lowerTick,
            uppperTick
        );
        amount0 = 0.998976618347425280 ether;
        amount1 = 5000 ether;

        liquidity += uint128(amount);

        uint256 balance0Before;
        uint256 balance1Before;
        if (amount0 > 0) {
            balance0Before = balance0();
        }
        if (amount1 > 0) {
            balance1Before = balance1();
        }
        IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(
            amount0,
            amount1
        );
        if (amount0 > 0 && balance0Before + amount0 > balance0()) {
            revert("UniswapV3Pool: TOKEN0_INCONSISTENT");
        }
        if (amount1 > 0 && balance1Before + amount1 > balance1()) {
            revert("UniswapV3Pool: TOKEN1_INCONSISTENT");
        }
        emit Mint(owner, lowerTick, uppperTick, amount, amount0, amount1);
    }

    function balance0() internal returns (uint256 balance) {
        uint256 balance = IERC20(token0).balanceOf(address(this));
    }

    function balance1() internal returns (uint256 balance) {
        uint256 balance = IERC20(token1).balanceOf(address(this));
    }
}
