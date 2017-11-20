pragma solidity 0.4.18;

contract Wallet {

    address public owner;

    function Wallet() public {
        owner = msg.sender;
    }

}