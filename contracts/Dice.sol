pragma solidity ^0.4.10;

// Oracle interface
contract Oracle {
    address public cbAddress;
    function query(string _query) returns (bytes32 id);
}

// OracleResolver interface
contract OracleResolver {
    function getOracleAddress() constant returns(address);
}

// 給dapp開發者使用的合約
contract UsingMyOracle {
    OracleResolver resolver;
    Oracle oracle;

    modifier myOracleAPI {
        if (address(resolver) == 0) {
            // 指定OracleResolver的合約地址，要替換成你自己的
            resolver = OracleResolver(0xf915602Df295BdcB1cDB50cd0d1C8Ab3DcB8e271);
            oracle = Oracle(resolver.getOracleAddress());
        }
        _;
    }

    modifier onlyFromCbAddress {
        if (msg.sender != oracle.cbAddress()) throw;
        _;
    }
    
    function myOracleQuery(string _query) internal myOracleAPI returns(bytes32 id) {
        return oracle.query(_query);
    }

    function _callback(bytes32 _id, string result) onlyFromCbAddress {
        // do nothing, 只是確保Oracle有一個_callback可以使用
    }
}

// 要繼承UsingMyOracle
contract Dice is UsingMyOracle {
    address owner;
    mapping(address => bytes32) myids;
    mapping(bytes32 => string) dice_result;
    
    // 輔助的event，沒有也不影響功能
    event newMyOracleQuery(string description);
    event diceResult(string result);
    
    function Dice() {
        owner = msg.sender;
    }
    
    // 擲骰子
    function dice() {
        newMyOracleQuery("MyOracle query was sent, standing by for the answer..");
        bytes32 myid = myOracleQuery("0-1000"); //指定範圍
        myids[msg.sender] = myid;
    }
    
    // override
    function _callback(bytes32 _id, string result) onlyFromCbAddress {
        dice_result[_id] = result;
        diceResult(result);
    }
    
    function checkResult() constant returns (string) {
        return dice_result[myids[msg.sender]];
    }
}

