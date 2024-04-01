pragma solidity ^0.8.20;

library Position{
    struct Info{
        uint liquidity;
    }
    function update(Info storage self , uint128 liquidityDelta) internal{
        uint128 liquidityBefore = uint128(self.liquidity);
        uint128 liquidityAfter = liquidityBefore + liquidityDelta;
        self.liquidity = uint(liquidityAfter);
    }
    function get(
        mapping(bytes32=>Info) storage self,
        address owner,
        int24 lowerTick,
        int24 upperTick
    ) internal view returns (Position.Info storage position){
        bytes32 key = keccak256(abi.encodePacked(owner,lowerTick,upperTick));
        return self[key];
    }
}