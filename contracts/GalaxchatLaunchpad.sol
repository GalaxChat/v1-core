pragma solidity ^0.8.0;

import "./GalaxchatChatroomToken.sol";
import "./interfaces/IGalaxchatLaunchpad.sol";
import "./interfaces/ISwapV2.sol";
import "./interfaces/IWETH.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract GalaxchatLaunchpad is Ownable, ReentrancyGuard {
    event Invest(
        address indexed chatroom,
        address indexed owner,
        uint256 amount
    );

    event CreateLP(address indexed chatroom, address indexed owner);

    event Claim(
        address indexed chatroom,
        address indexed owner,
        uint256 amount
    );

    struct InvestOrder {
        address owner;
        uint256 amount;
    }

    struct Chatroom {
        GalaxchatChatroomToken token;
        address pair;
        uint256 status;
        uint256 totalFund;
    }

    ISwapV2 public router = ISwapV2(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);

    mapping(address => Chatroom) public chatroomStatus;

    mapping(address => InvestOrder[]) public chatroomInvests;

    mapping(address => mapping(address => bool)) public claimed;

    uint256 public minETHAmount = 0.1 ether;

    uint256 public platformETHShare = 3;

    uint256 public investorTokenShare = 30;

    uint256 public platformTokenShare = 3;

    uint256 public lpTokenShare = 15;

    uint256 public executorTokenShare = 2;

    function setRouter(ISwapV2 _router) external onlyOwner {
        router = _router;
    }

    function setMinETHAmount(uint256 _minETHAmount) external onlyOwner {
        minETHAmount = _minETHAmount;
    }

    function getChatroomInvestsLength(address _chatroom)
        external
        view
        returns (uint256)
    {
        return chatroomInvests[_chatroom].length;
    }

    function invest(address _chatroom) external payable nonReentrant {
        require(
            chatroomStatus[_chatroom].status == 0,
            "Galaxchat : You can't invest , Token has been created"
        );
        chatroomInvests[_chatroom].push(
            InvestOrder({owner: msg.sender, amount: msg.value})
        );
        chatroomStatus[_chatroom].totalFund += msg.value;
        emit Invest(_chatroom, msg.sender, msg.value);
    }

    function createToken(address _chatroom) external nonReentrant {
        require(
            chatroomStatus[_chatroom].status == 0,
            "Galaxchat : You can't create token , Token has been created"
        );
        require(
            chatroomStatus[_chatroom].totalFund > minETHAmount,
            "Galaxcaht : Chatroom totalFund must greater than minETHAmout"
        );

        string memory name = string(
            abi.encodePacked("Galaxchat Chatroom Token (", _chatroom, ")")
        );
        uint256 totalSupply = 10**10 * 10**18;

        GalaxchatChatroomToken token = new GalaxchatChatroomToken(
            name,
            name,
            totalSupply
        );
        IWETH weth = IWETH(router.WETH9());
        address pair = IUniswapV2Factory(router.factoryV2()).createPair(
            address(weth),
            address(token)
        );

        uint256 fee = (chatroomStatus[_chatroom].totalFund * platformETHShare) /
            100;

        token.transfer(pair, (totalSupply * lpTokenShare) / 100);
        token.transfer(msg.sender, (totalSupply * executorTokenShare) / 100);
        token.transfer(owner(), (totalSupply * platformTokenShare) / 100);

        payable(owner()).transfer(fee);
        uint256 pairAmount = chatroomStatus[_chatroom].totalFund - fee;
        weth.deposit{value: pairAmount}();
        weth.transfer(pair, pairAmount);
        IUniswapV2Pair(pair).mint(address(this));
        chatroomStatus[_chatroom].pair = pair;
        chatroomStatus[_chatroom].token = token;
        chatroomStatus[_chatroom].status = 1;
        emit CreateLP(_chatroom, msg.sender);
    }

    function getClaimAmount(address _chatroom) public view returns (uint256) {
        uint256 amount;
        for (uint256 i = 0; i < chatroomInvests[_chatroom].length; i++) {
            if (chatroomInvests[_chatroom][i].owner == msg.sender) {
                amount += chatroomInvests[_chatroom][i].amount;
            }
        }
        uint256 claimAmount = (chatroomStatus[_chatroom].token.totalSupply() *
            investorTokenShare *
            amount) /
            chatroomStatus[_chatroom].totalFund /
            100;
        uint256 remainingAmount = chatroomStatus[_chatroom].token.balanceOf(
            address(this)
        );
        if (remainingAmount < claimAmount) {
            claimAmount = remainingAmount;
        }
        return claimAmount;
    }

    function claim(address _chatroom) external nonReentrant {
        require(
            chatroomStatus[_chatroom].status == 1,
            "Galaxchat : LP must be created"
        );
        require(
            !claimed[_chatroom][msg.sender],
            "Galaxchat : The account has been claimed"
        );
        uint256 claimAmount = getClaimAmount(_chatroom);
        chatroomStatus[_chatroom].token.transfer(msg.sender, claimAmount);
        claimed[_chatroom][msg.sender] = true;
        emit Claim(_chatroom, msg.sender, claimAmount);
    }
}
