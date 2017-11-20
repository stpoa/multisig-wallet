pragma solidity ^0.4.15;


contract Wallet {

    address public creator;
    address[] public owners;

    function Wallet(address[] _owners) public {
        owners = _owners;
        creator = msg.sender;
    }

}
