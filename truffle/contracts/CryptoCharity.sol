pragma solidity ^0.4.21;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        //there is no case where this function can overflow/underflow
        uint256 c = a / b;
        return c;
    }
    
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract CryptoCharity {
    using SafeMath for uint;
    
    event LogDonation(address indexed from, uint value);
    event LogAddSubject(address indexed from, bytes32 title);
    event LogVoteForSubject(address indexed from, bytes32 index);
    event LogExecuteSubject(uint index);
    event LogVoteForLocking(address indexed from);
    event LogRemoveVoteForLocking(address indexed from);
    event LogTransferVotePower(address indexed from, address to, uint votes);
    
    struct Person {
        uint votePower;
        uint lastTimeVote;
        uint lastTimeAddedSubject;
        bool canAddSubject;
    }
    
     struct Subject {
        address recipientAddres;
        uint votes;
        uint requiredEther;
        uint dateCreated;
        bool paid;
        bytes32 title;
        bytes32 description;
    }
    
    struct LockPerson {
        uint votes;
        bool hasVoted;
    }
    
    enum ContractStage {Starting, InAction, Locked}
    
    ContractStage private contractStage;
    
    mapping(address => Person) private members;
    mapping(address => LockPerson) private membersVotesForLock;
    
    uint private totalVotesForLock;
    uint public totalMembers;
    uint private totalVotes;
    uint private subjectTime;
    uint private currentWeekTime;
    uint private weekLength;
    
    bool private canAddSubject;
    
    Subject private subjectForApprovel;
    
    modifier OnlyMembers () {
        require(members[msg.sender].votePower > 0);
        _;
    }
    
    modifier CanAddSubject() {
        require(members[msg.sender].canAddSubject == true);
        require(canAddSubject == true);
        _;
    }
    
    modifier OnlyStartOrInActionStage () {
        require(contractStage == ContractStage.Starting || contractStage == ContractStage.InAction);
        _;
    }
    
    modifier OnlyInActionStage () {
         require(contractStage == ContractStage.InAction);
        _;
    }
    
    modifier OnlyInActionOrLockedStage () {
         require(contractStage == ContractStage.Locked || contractStage == ContractStage.InAction);
        _;
    }
    
    function CryptoCharity(uint _weekLength) public {
        currentWeekTime = now;
        contractStage = ContractStage.Starting;
        weekLength = _weekLength;
        canAddSubject = true;
        subjectForApprovel.paid = true;
    }
    
    function exsecuteSubject() internal {
        if(subjectForApprovel.votes >= totalVotes.div(2).add(1)) {
            if(subjectForApprovel.requiredEther.mul(1 ether) > getBalance()){
                subjectForApprovel.recipientAddres.transfer(getBalance());
            }
            else {
                subjectForApprovel.recipientAddres.transfer(subjectForApprovel.requiredEther.mul(1 ether));
            }
            
            canAddSubject = true;
            subjectForApprovel.paid = true;
        }
        else if(currentWeekTime.add(weekLength) > now) {
            canAddSubject = true;
            subjectForApprovel.paid = true;
        }
    }
    
    function donateToCharity() public payable OnlyStartOrInActionStage {
        require(msg.value > 0);
        uint votes = msg.value.div(1 ether).mul(10);
        if(votes > 0) {
            if(members[msg.sender].votePower == 0) {
                totalMembers = totalMembers.add(1);
            }
            members[msg.sender].votePower = members[msg.sender].votePower.add(votes);
            totalVotes = totalVotes.add(votes);
            
            if(votes >= 10 && members[msg.sender].lastTimeAddedSubject == 0) {
                members[msg.sender].canAddSubject = true;
            }
        }
        
        if(totalMembers == 5) {
            contractStage = ContractStage.InAction;
        } 
        
        exsecuteSubject();
        
        emit LogDonation(msg.sender, msg.value);
    }
    
    function addSubject(address _recipientAddres, uint _requiredEther, bytes32 _title, bytes32 _description) public OnlyInActionStage OnlyMembers CanAddSubject{
        require(_requiredEther > 0);
        
        canAddSubject = false;
        members[msg.sender].canAddSubject = false;
        
        subjectForApprovel = Subject(_recipientAddres, 0, _requiredEther, now, false, _title, _description);
        
        emit LogAddSubject(msg.sender, _title);
    }
    
    function voteForSubject() public OnlyMembers OnlyInActionStage {
        require(members[msg.sender].lastTimeVote.add(weekLength) < now);
        require(members[msg.sender].votePower > 0);
        require(subjectForApprovel.requiredEther > 0);
        
        members[msg.sender].lastTimeVote = now;
        
        subjectForApprovel.votes = subjectForApprovel.votes.add(members[msg.sender].votePower);
        
        exsecuteSubject();
        
        emit LogVoteForSubject(msg.sender, subjectForApprovel.title);
    }
    
    function voteForLocking() public OnlyMembers OnlyInActionOrLockedStage {
        require(membersVotesForLock[msg.sender].hasVoted == false);
        membersVotesForLock[msg.sender].hasVoted = true;
        
        if(totalVotesForLock >= membersVotesForLock[msg.sender].votes) {
            totalVotesForLock = totalVotesForLock.sub(membersVotesForLock[msg.sender].votes);
        } 
        
        membersVotesForLock[msg.sender].votes = members[msg.sender].votePower;
        
        totalVotesForLock = totalVotesForLock.add(members[msg.sender].votePower);
        
        emit LogVoteForLocking(msg.sender);
        
        exsecuteSubject();
        
        if(totalVotesForLock > totalVotes.div(2).add(1)){
            contractStage = ContractStage.Locked;
        }
    }
    
    function removeVoteForLocking() public OnlyMembers OnlyInActionOrLockedStage {
        require(membersVotesForLock[msg.sender].hasVoted == true);
        membersVotesForLock[msg.sender].hasVoted = false;
        
        totalVotesForLock -= membersVotesForLock[msg.sender].votes;
        
        emit LogRemoveVoteForLocking(msg.sender);
        
        exsecuteSubject();
        
        if(totalVotesForLock < totalVotes.div(2).add(1)){
            contractStage = ContractStage.InAction;
        }
    }
    
    function transferVotePower(address _addr) public OnlyMembers OnlyInActionOrLockedStage {
        uint votePower = members[msg.sender].votePower;
        members[msg.sender].votePower = 0;
        members[_addr].votePower =  members[_addr].votePower.add(votePower);
        
        exsecuteSubject();
        
        emit LogTransferVotePower(msg.sender, _addr, votePower);
    }
    
    function getDonatePageInfo() public view returns(uint, uint, uint, uint,bool,ContractStage) {
        Person memory person = members[msg.sender];
        return (this.balance,totalVotes, person.votePower, person.lastTimeVote, person.canAddSubject,contractStage);
    }
    
    function getLockPageInfo() public view returns(ContractStage, uint, uint, uint, uint,bool) {
        return(contractStage, totalVotes, totalVotesForLock, members[msg.sender].votePower, membersVotesForLock[msg.sender].votes, membersVotesForLock[msg.sender].hasVoted);
    }
    
    function getAddPageInfo() public view returns (ContractStage, bool, bool) {
        return (contractStage, subjectForApprovel.paid, members[msg.sender].canAddSubject);
    }
    
    function getSubjectPageInfo() public view returns(address, uint,uint,uint,bytes32,bytes32,uint, bool, uint, ContractStage) {
        Subject memory sub = subjectForApprovel;
        return (sub.recipientAddres, sub.votes, sub.requiredEther, sub.dateCreated, sub.title, sub.description,totalVotes, sub.paid, this.balance, contractStage);
    }
    
    function getBalance() public view returns(uint) {
        return this.balance;
    }
}