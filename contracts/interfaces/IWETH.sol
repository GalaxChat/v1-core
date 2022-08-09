
interface IWETH {
    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);
}