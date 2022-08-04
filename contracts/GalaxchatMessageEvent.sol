pragma solidity ^0.8.0;

contract GalaxchatMessageEvent {
    uint256 public id;

    event Send(
        address indexed _chatroom,
        address indexed _sender,
        string _content,
        uint256 indexed _id
    );

    function send(
        address _chatroom,
        address _sender,
        string memory _content
    ) public {
        emit Send(_chatroom, _sender, _content, id++);
    }
}

