pragma solidity =0.8.15;

contract GalaxChatProtocol {
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

contract GalaxChatGroup {
    uint256 public id;

    event Send(
        address indexed _token,
        address indexed _owner,
        string _content,
        uint256 indexed _id
    );

    function send(address _address, string memory _content) public {
        _send(_address, _content);
    }

    function _send(address _address, string memory _content) internal {
        emit Srite(_address, msg.sender, _content, id++);
    }
}
