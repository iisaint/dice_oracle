pragma solidity ^0.4.10;

contract Oracle {
    address owner;
    address public cbAddress; // callback address

    function Oracle() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    event QueryEvent(bytes32 id, string query);

    function setCbAddress(address _cbAddress) onlyOwner {
        cbAddress = _cbAddress;
    }

    function query(string _query) returns (bytes32 id) {
        id = sha3(block.number, now, _query, msg.sender);
        QueryEvent(id, _query);
        return id;
    }
}
