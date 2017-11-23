pragma solidity 0.4.18;


contract Wallet {

    //--- Strcutures
    struct TransactionProposal {
        mapping(address => bool) confirmedBy;
        uint confirmationsCount;
        bool executed;
    }

    struct OwnersChangeProposal {
        bytes32 newOwnersHash;
        mapping (address => bool) votes;
        uint votesCount;
    }

    //--- Variables
    address[] public owners;
    mapping (bytes32 => TransactionProposal) public transactions;
    OwnersChangeProposal public ownersChangeProposal;

    //--- Events
    event Deposited(address user, uint value);
    event Transferred(address destination, uint value);
    event TransferCalled(bytes32 transactionHash, address user);

    //--- Modifiers
    modifier onlyowner {
        require(isOwner(msg.sender));
        _;
    }

    //--- Constructor
    function Wallet (address[] _owners) public {
        setOwners(_owners);
    }

    //--- Public view methods
    function isOwner (address _user) public view returns (bool) {
        for (uint i = 0; i < owners.length; ++i) {
            if (owners[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function changeOwnerConfirmedByAll () public view returns (bool) {
        return ownersChangeProposal.votesCount == owners.length;
    }

    function getBalance () public view returns (uint) {
        return this.balance;
    }

    function confirmationCount(bytes32 transactionHash) public view returns (uint) {
        return transactions[transactionHash].confirmationsCount;
    }

    function isConfirmedByAll (bytes32 transactionHash) public view onlyowner returns (bool) {
        return transactions[transactionHash].confirmationsCount == owners.length;
    }

    //--- Public payable methods
    function deposit () public payable {
        Deposited(msg.sender, msg.value);
    }

    //--- Public restricted to owner methods
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

    function changeOwner (address[] _newOwners) public onlyowner {
        bytes32 _newOwnersHash = keccak256(_newOwners, owners);

        if (_newOwnersHash == ownersChangeProposal.newOwnersHash) {
            // Check if not voted already
            require(!ownersChangeProposal.votes[msg.sender]);

            // Vote for proposal
            ownersChangeProposal.votes[msg.sender] = true;
            ownersChangeProposal.votesCount++;
        } else {
            // Reset votes and create new proposal
            resetNewOwnersVotes();
            ownersChangeProposal.newOwnersHash = _newOwnersHash;
            ownersChangeProposal.votes[msg.sender] = true;
            ownersChangeProposal.votesCount = 1;
        }

        if (changeOwnerConfirmedByAll()) {
            // Execute owners change
            resetNewOwnersVotes();
            setOwners(_newOwners);
        }
    }

    //--- Private Methods
    function setOwners (address[] newOwners) private {
        owners = newOwners;
    }

    function resetNewOwnersVotes () private {
        for (uint i = 0; i < owners.length; ++i) {
            ownersChangeProposal.votes[owners[i]] = false;
        }
        ownersChangeProposal.votesCount = 0;
    }

    function executeTransfer (address destination, uint value) private onlyowner {
        destination.transfer(value);
        Transferred(destination, value);
    }

}
