pragma solidity ^0.4.15;


contract Wallet {

    //-- Types
    struct PendingTransfer {
        address from;
        address to;
        uint amount;
        uint timestamp;
    }

    //-- Variables
    address public creator;
    address[] public owners;
    mapping (address => bool) public isOwner;

    //-- Events
    //event Deposited(address, uint);

    // Methods
    function Wallet(address[] _owners) public {
        creator = msg.sender;
        owners = _owners;

        for (uint i = 0; i < _owners.length; ++i) {
            isOwner[_owners[i]] = true;
        }
    }

    /* function deposit () public payable {
        Deposited(msg.sender, msg.value);
    }

    function transfer (uint _value) public {
        msg.sender.transfer(_value);
    } */

}

