// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IERC20Minimal.sol";

/// @title GetPoolData
/// @notice Contract retrieves data from Uniswap v3 pools
contract GetPoolData {
    // The address of the Uniswap v3 factory on Ethereum mainnet.
    address uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address poolAddress;
    address token0;
    address token1;

    IUniswapV3Factory factory = IUniswapV3Factory(uniswapV3Factory);
    IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);

    /// @notice Retrieves the virtual reserves of token0 in the pool
    function getToken0virtualReserve() external view returns (uint256) {
        return _getVirtualReserves(token0);
    }

    /// @notice Retrieves the virtual reserves of token1 in the pool
    function getToken1virtualReserve() external view returns (uint256) {
        return _getVirtualReserves(token1);
    }

    // fee = 500 || 3000 || 10000
    function setPoolAddress(
        address _token0,
        address _token1,
        uint24 _feeOfPool
    ) public returns (address) {
        token0 = _token0;
        token1 = _token1;
        poolAddress = factory.getPool(_token0, _token1, _feeOfPool);
        return poolAddress;
    }

    /// @notice Returns the current tick of the pool
    function getCurrentTick() public view returns (int24 tick) {
        (, tick, , , , , ) = pool.slot0();
    }

    /// @notice Internal function for calculating the virtual reserves of proper token
    /// @dev function gives the information about the current tick
    /// @param _token address of the token to find out its virtual reserves
    function _getVirtualReserves(
        address _token
    ) internal view returns (uint256) {
        // Get the current state of the pool
        (uint160 sqrtPriceX96, , uint256 liquidity, , , , ) = pool.slot0();

        // Calculate the amount of `token0` virtual reserves
        uint256 sqrtPrice = uint256(sqrtPriceX96);
        uint256 price = (sqrtPrice * sqrtPrice) / 2 ** 96;
        uint256 virtualReserves = (IERC20Minimal(_token).balanceOf(
            poolAddress
        ) *
            price *
            liquidity) / (2 ** (2 * 96));

        return virtualReserves;
    }
}
