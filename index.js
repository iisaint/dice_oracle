const fs = require('fs');
const Web3 = require('web3');
const solc = require('solc');
const _ = require('lodash');

// config
const ethereumUri = 'http://localhost:8545';
const callbackAddr = '0x00A79a80Fb0ff9216AAC81AD416D8f8AA2a6dDB9';//替換成剛剛設定的cbAddress
const password = 'password'; //替換成可以unlock callbackAddr的密碼
const oracleAddr = '0xC4Eb879Cd65C4A2F4B4Afc50a657fF6Aee77Ba31';
const diceAddr = '0x15f330d188907cb60C0178F2B7EBCdeE952F5e74';

// connect to node
let web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider(ethereumUri));

if (!web3.isConnected()) {
    throw new Error('unable to connect to ethereum node at ' + ethereumUri);
} else {
    console.log('connected to ehterum node at ' + ethereumUri);
    web3.eth.defaultAccount = callbackAddr;
}

// compile contract
let oracle = _compileContract('Oracle', oracleAddr);
let dice = _compileContract('Dice', diceAddr);

// watch QueryEvent
let event = oracle.instance.QueryEvent();
console.log('watching for QueryEvent...\n');
event.watch(function (error, result) {
    if (!error) {
        console.log('got a QueryEvent');
        // get query id
        var id = _.at(result, 'args.id');
        // get query string
        var query = _.split(_.at(result, 'args.query'), '-', 2);
        // generate a random number according to query string
        var value = _randomIntInc(query[0], query[1]);

        // must to unlock the cbAddress before firing
        web3.personal.unlockAccount(web3.eth.defaultAccount, password);
        console.log(`fire _callback(${id[0]}, ${value}) back to Dice`);
        let txid = dice.instance._callback(id[0], '' + value, {gas: 200000});
        console.log(`txid = ${txid}`)
    } else {
        console.log(error);
    }
    console.log('----------------------------------------------------------------');
});

/**
 * Compile contract to get necessary information.
 * @param {string} name Contract name.
 * @param {string} address Address of deployed contract. 
 */
function _compileContract(name, address) {

    let source = fs.readFileSync("./contracts/"+name+'.sol', 'utf8');
    console.log(`compile ${name}.sol`);

    let compiledContract = solc.compile(source);

    var bytecode = _.at(compiledContract, 'contracts.:' + name + '.bytecode');
    var abi = JSON.parse(_.at(compiledContract, 'contracts.:' + name + '.interface'));

    var contract = web3.eth.contract(abi);
    var instance = contract.at(address);

    return {
        'abi': abi,
        'instance': instance
    };
}

/**
 * Generate a random number between low and high.
 * @param {number} low 
 * @param {number} high 
 */
function _randomIntInc(low, high) {
    return Math.floor(Math.random() * (high - low + 1) + low);
}

(function wait() {
    setTimeout(wait, 1000);
})();
