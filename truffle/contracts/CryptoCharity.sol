pragma solidity ^0.4.18;

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

library SubjectLib {
    using SafeMath for uint;
    
    struct Subject {
        address recipientAddres;
        uint votes;
        uint requiredEther;
        uint dateCreated;
        string title;
        string description;
        string feedback;
    }
    
    function transferToRecipient (Subject storage self, uint amount) public {
        self.recipientAddres.transfer(amount);
    }
    
    
    
    /*
    function memberHasTimedOut(Subject storage self) public view returns (bool) {
        if(self.lastDonation.add(1 hours) < now) { //the member didn't donate and must be removed
            return true;
        }
        
        return false;
    }
    
    function remove(Subject storage self) public {
        self.adr = 0;
    }
    
    function initialize(Subject storage self, address adr) public {
        self.adr = adr;
        self.lastDonation = now; //give the new member time to donate so he isn't kicked right away
    }
    
    function update(Subject storage self, uint donatedValue) public {
        self.lastValue = donatedValue;
        self.lastDonation = now;
        self.totalValue = self.totalValue.add(donatedValue);
    }
    */
}

library PersonLib {
    using SafeMath for uint;
    
    struct Person {
        uint votePower;
        uint lastTimeVote;
    }
    
}

contract CryptoCharity {
    using SafeMath for uint;
    using SubjectLib for SubjectLib.Subject;
    using PersonLib for PersonLib.Person;
    
    enum ContractStage {Starting, InAction, Locked}
    
    ContractStage public contractStage;
    
    mapping(address => PersonLib.Person) private members;
    
    mapping(address => uint) private membersVotesForLock;
    
    uint public totalVotesForLock;
    
    uint public totalMembers;
    
    uint public lastTimeExecuteSubject;
    
    uint public currentWeekTime;
    
    uint public mostVotedSubjectIndex;
    
    uint public remainingSubjectsForAddThisWeek;
    
    SubjectLib.Subject[] public approvedSubjects;
    
    SubjectLib.Subject[] public subjectsForApprovel;
    
    modifier OnlyMembers () {
        require(members[msg.sender].votePower > 0);
        _;
    }
    
    modifier IsSubjectValid(uint index) {
        require(subjectsForApprovel.length < index);
        require(subjectsForApprovel[index].dateCreated.add(7 days) > now);
        _;
    }
    
    modifier isStartingStage () {
        require(contractStage == ContractStage.Starting);
        _;
    }
    
    modifier isInActionStage () {
         require(contractStage == ContractStage.InAction);
        _;
    }
    
    modifier isLockedStage () {
         require(contractStage == ContractStage.Locked);
        _;
    }
    
    function CryptoCharity() public {
        currentWeekTime = now;
        contractStage = ContractStage.Starting;
        remainingSubjectsForAddThisWeek = 5;
    }
    
    function updateMostVotedSubjectIndex (uint votes, uint index) internal {
        if(votes > mostVotedSubjectIndex) {
            mostVotedSubjectIndex = index;
        }
    }
    
    function exsecuteSubject() internal IsSubjectValid(mostVotedSubjectIndex) {
        if(lastTimeExecuteSubject.add(7 days) < now){
            SubjectLib.Subject memory sub = subjectsForApprovel[mostVotedSubjectIndex];
            
            if(sub.votes >= totalMembers.div(2)){
                uint amountToSend = 0;
                if(sub.requiredEther.mul(1 ether) > getBalance()){
                    amountToSend = getBalance();
                }
                else {
                    amountToSend = sub.requiredEther.mul(1 ether);
                }
                
                subjectsForApprovel[mostVotedSubjectIndex].transferToRecipient(amountToSend);
                
                approvedSubjects.push(sub);
            }
            currentWeekTime = now;
            remainingSubjectsForAddThisWeek = 5;
        }
    }
    
    function donateToCharity() public payable {
        exsecuteSubject();
        uint votes = msg.value.mul(10).div(1 ether);
        if(votes > 0) {
            if(members[msg.sender].votePower == 0) {
                totalMembers.add(1);
            }
            members[msg.sender].votePower = members[msg.sender].votePower.add(votes);
            
        }
    }
    
    function addSubject(address _recipientAddres, uint _requiredEther, string _title, string _description) public {
        require(remainingSubjectsForAddThisWeek > 0);
        exsecuteSubject();
        remainingSubjectsForAddThisWeek = remainingSubjectsForAddThisWeek.sub(1);
        subjectsForApprovel.push(SubjectLib.Subject(_recipientAddres, 0, _requiredEther, now, _title, _description, ""));
    }
    
    function voteForSubject(uint index) public OnlyMembers IsSubjectValid(index) {
        require(members[msg.sender].lastTimeVote.add(7 days) < now);
        require(members[msg.sender].votePower > 0);
        exsecuteSubject();
        
        members[msg.sender].lastTimeVote = now;
        
        subjectsForApprovel[index].votes = subjectsForApprovel[index].votes.add(members[msg.sender].votePower);
        
        updateMostVotedSubjectIndex(subjectsForApprovel[index].votes, index);
    }
    
    function feedBackSubject(uint _index, string _string) public IsSubjectValid(_index) {
        require(approvedSubjects[_index].recipientAddres == msg.sender);
        exsecuteSubject();
        
        approvedSubjects[_index].feedback = _string;
    }
    
    function voteForLocking() public OnlyMembers {
        exsecuteSubject();
        
        membersVotesForLock[msg.sender] = members[msg.sender].votePower;
        
        totalVotesForLock = totalVotesForLock.add(members[msg.sender].votePower);
        
        if(totalVotesForLock > totalMembers.div(2)){
            contractStage = ContractStage.Locked;
        }
    }
    
    function removeVoteForLocking() public OnlyMembers {
        require(membersVotesForLock[msg.sender] > 0);
        exsecuteSubject();
        
        totalVotesForLock = totalVotesForLock.sub(membersVotesForLock[msg.sender]);
        
        
        if(totalVotesForLock < totalMembers.div(2)){
            contractStage = ContractStage.InAction;
        }
    }
    
    function getAllSubjects() public view returns(SubjectLib.Subject[]) {
        return subjectsForApprovel;
    }
    
    function getAllApprovedSubjects() public view returns(SubjectLib.Subject[]) {
        return approvedSubjects;
    }
    
    function getBalance() public view returns(uint){
        return this.balance;
    }
    
    // TODO transfer vote ownership
}