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
    event LogFeedBack(address indexed from, uint index);
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
    
    enum ContractStage {Starting, InAction, Locked}
    
    ContractStage public contractStage;
    
    mapping(address => Person) public members;
    mapping(address => uint) private membersVotesForLock;
    
    uint public totalVotesForLock;
    uint public totalMembers;
    uint public totalVotes;
    uint public subjectTime;
    uint public currentWeekTime;
    uint public weekLength;
    
    bool public canAddSubject;
    
    Subject public subjectForApprovel;
    
    modifier OnlyMembers () {
        require(members[msg.sender].votePower > 0);
        _;
    }
    
    modifier CanAddSubject() {
        require(members[msg.sender].lastTimeAddedSubject.add(weekLength) < now);
        _;
    }
    
    modifier OnlyStartingStage () {
        require(contractStage == ContractStage.Starting);
        _;
    }
    
    modifier OnlyInActionStage () {
         require(contractStage == ContractStage.InAction);
        _;
    }
    
    modifier OnlyLockedStage () {
         require(contractStage == ContractStage.Locked);
        _;
    }
    
    function CryptoCharity(uint _weekLength) public {
        currentWeekTime = now;
        contractStage = ContractStage.InAction;
        weekLength = _weekLength;
        canAddSubject = true;
    }
    
    function exsecuteSubject() internal {
        if(subjectForApprovel.votes.mul(2) > totalVotes) {
            if(subjectForApprovel.requiredEther > getBalance()){
                subjectForApprovel.recipientAddres.transfer(getBalance());
            }
            else {
                subjectForApprovel.recipientAddres.transfer(subjectForApprovel.requiredEther * 1 ether);
            }
            
            canAddSubject = true;
            subjectForApprovel.paid = true;
        }
        else if(currentWeekTime.add(weekLength) > now) {
            canAddSubject = true;
        }
    }
    
    function donateToCharity() public payable {
        uint votes = msg.value.div(1 ether).mul(10);
        if(votes > 0) {
            if(members[msg.sender].votePower == 0) {
                totalMembers.add(1);
            }
            members[msg.sender].votePower = members[msg.sender].votePower.add(votes);
            totalVotes = totalVotes.add(votes);
            
            if(votes > 10) {
                members[msg.sender].canAddSubject = true;
            }
        }
        
       
        
        /*
        if(totalMembers > 5) {
            
        } 
        */
        contractStage = ContractStage.InAction;
        
        emit LogDonation(msg.sender, msg.value);
    }
    
    function addSubject(address _recipientAddres, uint _requiredEther, bytes32 _title, bytes32 _description) public OnlyInActionStage OnlyMembers CanAddSubject{
        require(members[msg.sender].canAddSubject == true);
        require(canAddSubject == true);
        
        canAddSubject = false;
        members[msg.sender].canAddSubject = false;
        
        subjectForApprovel = Subject(_recipientAddres, 0, _requiredEther, now, false, _title, _description);
        
        members[msg.sender].lastTimeAddedSubject = now;
        
        emit LogAddSubject(msg.sender, _title);
    }
    
    function voteForSubject() public OnlyMembers OnlyInActionStage {
        require(members[msg.sender].lastTimeVote.add(weekLength) < now);
        require(members[msg.sender].votePower > 0);
        
        members[msg.sender].lastTimeVote = now;
        
        subjectForApprovel.votes = subjectForApprovel.votes.add(members[msg.sender].votePower);
        
        exsecuteSubject();
        
        emit LogVoteForSubject(msg.sender, subjectForApprovel.title);
    }
    
    function voteForLocking() public OnlyMembers {
        membersVotesForLock[msg.sender] = members[msg.sender].votePower;
        
        totalVotesForLock = totalVotesForLock.add(members[msg.sender].votePower);
        
        emit LogVoteForLocking(msg.sender);
        
        if(totalVotesForLock > totalMembers.div(2)){
            contractStage = ContractStage.Locked;
        }
    }
    
    function removeVoteForLocking() public OnlyMembers {
        require(membersVotesForLock[msg.sender] > 0);
        
        totalVotesForLock = totalVotesForLock.sub(membersVotesForLock[msg.sender]);
        
        emit LogRemoveVoteForLocking(msg.sender);
        
        if(totalVotesForLock < totalMembers.div(2)){
            contractStage = ContractStage.InAction;
        }
    }
    
    function transferVotePower(address _addr) public OnlyMembers {
        uint votePower = members[msg.sender].votePower;
        members[msg.sender].votePower = 0;
        members[_addr].votePower =  members[_addr].votePower.add(votePower);
        
        emit LogTransferVotePower(msg.sender, _addr, votePower);
    }
    
    function getDonatePageInfo() public view returns(uint, uint, uint, uint) {
        Person memory person = members[msg.sender];
        return (this.balance, person.votePower, person.lastTimeVote, person.lastTimeAddedSubject);
    }
    
    function getBalance() public view returns(uint){
        return this.balance;
    }
    
    function getSubject() public view returns(address, uint,uint,uint,bytes32,bytes32,uint, bool) {
        Subject memory sub = subjectForApprovel;
        return (sub.recipientAddres, sub.votes, sub.requiredEther, sub.dateCreated, sub.title, sub.description,totalVotes, sub.paid);
    }
    
    function getPerson() public view returns(uint, uint, uint, bool) {
        Person memory pes = members[msg.sender];
        return (pes.votePower, pes.lastTimeVote, pes.lastTimeAddedSubject, pes.canAddSubject);
    }
}