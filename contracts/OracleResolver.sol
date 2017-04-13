pragma solidity ^0.4.10;

contract OracleResolver {
    address owner;

    address public oracleAddress;

    function OracleResolver() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function setOracleAddress(address _addr) onlyOwner {
        oracleAddress = _addr;
    }
    
    function getOracleAddress() constant returns(address) {
        return oracleAddress;
    }
}

