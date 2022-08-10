pragma solidity ^0.8.0;

import "./interfaces/IGalaxChatAnonymousChat.sol";

contract GalaxChatAnonymousChat is IGalaxChatAnonymousChat {
    event Register(address indexed owner, uint256 dhKey);

    event Send(address indexed from, address indexed to, string data);

    uint256 public g = 47826432424213;

    uint256 public p = 317236187678563287461876384;

    //Diffie-Hellman key exchange
    mapping(address => uint256) public dhKey;

    //Dhkey=g**key%p
    function register(uint256 _dhKey) external {
        dhKey[msg.sender] = _dhKey;
        emit Register(msg.sender, _dhKey);
    }

    function send(string memory _data, address _to) external {
        require(
            dhKey[msg.sender] != 0,
            "GalaxChatProtocol : Sender must be registered"
        );
        require(
            dhKey[_to] != 0,
            "GalaxChatProtocol : Recipient must be registered"
        );
        emit Send(msg.sender, _to, _data);
    }
}
