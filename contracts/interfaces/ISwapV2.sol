pragma solidity ^0.8.0;

interface ISwapV2 {
    /// @return Returns the address of the Uniswap V2 factory
    function factoryV2() external view returns (address);

    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
}