pragma solidity 0.4.18;


contract Wallet {

    //--- Strcutures
    struct Transaction {
        mapping(address => bool) confirmedBy;
        uint confirmationsCount;
        bool executed;
    }

    //--- Variables
    address[] public owners;
    mapping (address => bool) public isOwner;
    mapping (bytes32 => Transaction) public transactions;

    bytes32 public proposedNewOwnersHash;
    mapping (address => bool) public votesForNewOwners;
    uint public votesForNewOwnersCount;

    //--- Events
    event Deposited(address user, uint value);
    event Transferred(address destination, uint value);
    event TransferCalled(bytes32 transactionHash, address user);

    //--- Modifiers
    modifier onlyowner {
        require(isOwner[msg.sender]);
        _;
    }

    //--- Methods
    function Wallet(address[] _owners) public {
        setOwners(_owners);
    }

    function changeOwner (address[] _newOwners) public onlyowner {
        bytes32 _newOwnersHash = keccak256(_newOwners, owners);

        if (_newOwnersHash == proposedNewOwnersHash) {
            // Check if not voted already
            require(!votesForNewOwners[msg.sender]);

            // Vote for proposal
            votesForNewOwners[msg.sender] = true;
            votesForNewOwnersCount++;
        } else {
            // Reset votes and create new proposal
            resetNewOwnersVotes();
            proposedNewOwnersHash = _newOwnersHash;
            votesForNewOwners[msg.sender] = true;
            votesForNewOwnersCount = 1;
        }

        if (changeOwnerConfirmedByAll()) {
            // Execute owners change
            resetNewOwnersVotes();
            setOwners(_newOwners);
        }
    }

    function changeOwnerConfirmedByAll () public view returns (bool) {
        return votesForNewOwnersCount == owners.length;
    }

    function getBalance () public view returns (uint) {
        return this.balance;
    }

    function deposit () public payable {
        Deposited(msg.sender, msg.value);
    }

    function transfer (address destination, uint value) public onlyowner {
        bytes32 transactionHash = keccak256(destination, value, owners);

        // Check if user already confirmed and if already all confirmations
        require(!transactions[transactionHash].confirmedBy[msg.sender]);
        require(!transactions[transactionHash].executed);

        // Confirm transfer
        transactions[transactionHash].confirmedBy[msg.sender] = true;
        transactions[transactionHash].confirmationsCount++;

        // Execute transfer
        if (isConfirmedByAll(transactionHash)) {
            delete transactions[transactionHash].confirmationsCount;
            transactions[transactionHash].executed = true;
            executeTransfer(destination, value);
        }
        TransferCalled(transactionHash, msg.sender);
    }

    function confirmationCount(bytes32 transactionHash) public view returns (uint) {
        return transactions[transactionHash].confirmationsCount;
    }

    function isConfirmedByAll (bytes32 transactionHash) public view onlyowner returns (bool) {
        return transactions[transactionHash].confirmationsCount == owners.length;
    }

    //--- Private Methods
    function setOwners (address[] newOwners) private {
        owners = newOwners;

        for (uint i = 0; i < owners.length; ++i) {
            isOwner[owners[i]] = false;
        }
        for (uint j = 0; j < newOwners.length; ++j) {
            isOwner[newOwners[j]] = true;
        }
    }

    function resetNewOwnersVotes () private {
        for (uint i = 0; i < owners.length; ++i) {
            votesForNewOwners[owners[i]] = false;
        }
        votesForNewOwnersCount = 0;
    }

    function executeTransfer (address destination, uint value) private onlyowner {
        destination.transfer(value);
        Transferred(destination, value);
    }

}
