pragma solidity ^0.8.20;


library Tick{
    struct Info{
        bool initialized;
        uint128 liquidity;
    }

    function update(
        mapping(int24 => Tick.Info) storage self,
        int24 tick,
        uint128 liquidity
    ) internal {
        Tick.Info storage tickInfo = self[tick];
        uint128 liquidityBefore = uint128(tickInfo.liquidity);
        uint128 liquidityAfter = liquidityBefore + uint128(liquidity);
        if (liquidityBefore == 0){
            tickInfo.initialized = true;
        }
        tickInfo.liquidity = uint128(liquidityAfter);
    }
}