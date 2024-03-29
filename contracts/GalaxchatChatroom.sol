pragma solidity ^0.8.0;

import "./interfaces/IGalaxChatChatroom.sol";

contract GalaxChatChatroom is IGalaxChatChatroom {
    uint256 public id;

    event Send(
        address indexed _chatroom,
        address indexed _sender,
        string _content,
        uint256 indexed _id,
        uint256 timestamp
    );

    function send(
        address _chatroom,
        address _sender,
        string calldata _content
    ) public {
        emit Send(_chatroom, _sender, _content, id++, block.timestamp);
    }
}
