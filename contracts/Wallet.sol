pragma solidity 0.4.18;


contract Wallet {

    //--- Structures
    struct TransactionProposal {
        mapping(address => bool) confirmedBy;
        uint256 confirmationsCount;
        bool initiated;
    }

    struct OwnersChangeProposal {
        bytes32 newOwnersHash;
        mapping (address => bool) votes;
        uint256 votesCount;
    }

    //--- Variables
    address[] public owners;
    mapping (bytes32 => TransactionProposal) public transactions;
    OwnersChangeProposal public ownersChangeProposal;

    //--- Events
    event Deposited(address user, uint256 value);
    event Transferred(address destination, uint256 value);
    event TransferCalled(bytes32 transactionHash, address user);

    //--- Modifiers
    modifier onlyOwner {
        require(isOwner(msg.sender));
        _;
    }

    //--- Constructor
    function Wallet(address[] _owners) public {
        setOwners(_owners);
    }

    //--- Public view methods
    function isOwner(address _user) public view returns (bool) {
        for (uint256 i = 0; i < owners.length; ++i) {
            if (owners[i] == _user) {
                return true;
            }
        }

        return false;
    }

    function getOwners() public view returns (address[]) {
        return owners;
    }

    //--- Public payable methods
    function deposit() public payable {
        require(msg.value > 0);

        Deposited(msg.sender, msg.value);
    }

    //--- Public restricted to owner methods
    function transfer(address destination, uint256 value) public onlyOwner {
        bytes32 _transactionHash = keccak256(destination, value, owners);

        TransactionProposal storage proposal = transactions[_transactionHash];

        // Check if user already confirmed
        require(!proposal.confirmedBy[msg.sender]);

        // Set transaction to initiated
        if (!proposal.initiated) {
            proposal.initiated = true;
        }

        // Confirm transfer
        proposal.confirmedBy[msg.sender] = true;
        proposal.confirmationsCount++;

        // Execute transfer
        if (transferConfirmedByAll(proposal)) {
            clearTransaction(_transactionHash);

            destination.transfer(value);
            Transferred(destination, value);
        }

        TransferCalled(_transactionHash, msg.sender);
    }

    function changeOwners(address[] newOwners) public onlyOwner {
        bytes32 newOwnersHash = keccak256(newOwners, owners);

        if (ownersChangeProposal.newOwnersHash == bytes32(0)) {
            ownersChangeProposal.newOwnersHash = newOwnersHash;
        } else {
            require(newOwnersHash == ownersChangeProposal.newOwnersHash);

            // Check if not voted already
            require(!ownersChangeProposal.votes[msg.sender]);
        }

        // Vote for proposal
        ownersChangeProposal.votes[msg.sender] = true;
        ownersChangeProposal.votesCount++;

        if (changeOwnerConfirmedByAll()) {
            clearOwnersChangeProposal();
            setOwners(newOwners);
        }
    }

    function cancelChangeOwners() public onlyOwner {
        clearOwnersChangeProposal();
    }

    //--- Private Methods
    function transferConfirmedByAll(TransactionProposal storage proposal) private view returns (bool) {
        return proposal.confirmationsCount == owners.length;
    }

    function changeOwnerConfirmedByAll() private view returns (bool) {
        return ownersChangeProposal.votesCount == owners.length;
    }

    function setOwners(address[] newOwners) private {
        owners = newOwners;
    }

    function clearOwnersChangeProposal() private {
        for (uint256 i = 0; i < owners.length; ++i) {
            delete ownersChangeProposal.votes[owners[i]];
        }

        delete ownersChangeProposal;
    }

    function clearTransaction(bytes32 _transactionHash) private {
        TransactionProposal storage proposal = transactions[_transactionHash];

        for (uint256 i = 0; i < owners.length; ++i) {
            delete proposal.confirmedBy[owners[i]];
        }

        delete transactions[_transactionHash];
    }
}
