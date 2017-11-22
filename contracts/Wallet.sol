pragma solidity 0.4.18;


contract Wallet {

    //--- Variables
    address public creator;
    address[] public owners;
    mapping (address => bool) public isOwner;
    mapping (bytes32 => mapping(address => bool)) public transactions;
    mapping (bytes32 => uint) public confirmationCounts;
    mapping (bytes32 => bool) public executed;

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
        creator = msg.sender;
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
        require(!transactions[transactionHash][msg.sender]);
        require(!executed[transactionHash]);

        // Confirm transfer
        transactions[transactionHash][msg.sender] = true;
        confirmationCounts[transactionHash]++;

        // Execute transfer
        if (isConfirmedByAll(transactionHash)) {
            delete confirmationCounts[transactionHash];
            executed[transactionHash] = true;
            executeTransfer(destination, value);
        }
        TransferCalled(transactionHash, msg.sender);
    }

    function isConfirmedByAll (bytes32 transactionHash) public view onlyowner returns (bool) {
        return confirmationCounts[transactionHash] == owners.length;
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
