pragma solidity ^0.4.19;

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
        bytes32 title;
        bytes32 description;
        bytes32 feedback;
    }
    
    function transferToRecipient (Subject storage _self, uint _amount) public {
        _self.recipientAddres.transfer(_amount);
    }
    
    function updateSubjectVotes (Subject storage _self, uint _votes) public {
        _self.votes = _self.votes.add(_votes);
    }
    
    function updateFeedback (Subject storage _self, bytes32 _text) public {
        _self.feedback = _text;
    }
}

library PersonLib {
    using SafeMath for uint;
    
    struct Person {
        uint votePower;
        uint lastTimeVote;
        uint lastTimeAddedSubject;
    }
    
    function updateVotePower(Person storage _self, uint _votes) public {
        _self.votePower = _votes;
    }
    
    function deleteVotePower(Person storage _self) public {
        _self.votePower = 0;
    }
    
    function updateLastTimeVoteed(Person storage _self) public {
        _self.lastTimeVote = now;
    }
    
    function updateLastTimeAddedSubject(Person storage _self) public {
        _self.lastTimeAddedSubject = now;
    }
}

contract CryptoCharity {
    using SafeMath for uint;
    using SubjectLib for SubjectLib.Subject;
    using PersonLib for PersonLib.Person;
    
    event LogDonation(address indexed from, uint value);
    event LogAddSubject(address indexed from, uint index);
    event LogVoteForSubject(address indexed from, uint index);
    event LogExecuteSubject(uint index);
    event LogFeedBack(address indexed from, uint index);
    event LogVoteForLocking(address indexed from);
    event LogRemoveVoteForLocking(address indexed from);
    event LogTransferVotePower(address indexed from, address to, uint votes);
    
    enum ContractStage {Starting, InAction, Locked}
    
    ContractStage public contractStage;
    
    mapping(address => PersonLib.Person) private members;
    mapping(address => uint) private membersVotesForLock;
    
    uint public totalVotesForLock;
    uint public totalMembers;
    uint public lastTimeExecuteSubject;
    uint public currentWeekTime;
    uint public mostVotesForSubject;
    uint public mostVotedSubjectIndex;
    uint public remainingSubjectsForAddThisWeek;
    uint public weekLength;
    
    SubjectLib.Subject[] public approvedSubjects;
    SubjectLib.Subject[] public subjectsForApprovel;
    
    modifier OnlyMembers () {
        require(members[msg.sender].votePower > 0);
        _;
    }
    
    modifier OnlyValidSubject(uint _index) {
        require(subjectsForApprovel.length < _index);
        require(subjectsForApprovel[_index].dateCreated.add(weekLength) > currentWeekTime);
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
        contractStage = ContractStage.Starting;
        weekLength = _weekLength;
        remainingSubjectsForAddThisWeek = 9;
    }
    
    function updateMostVotedSubjectIndex (uint _votes, uint _index) internal {
        if(_votes > mostVotesForSubject) {
            mostVotedSubjectIndex = _index;
            mostVotesForSubject = _votes;
        }
    }
    
    function exsecuteSubject() internal OnlyValidSubject(mostVotedSubjectIndex) {
        if(lastTimeExecuteSubject.add(weekLength) < now){
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
            mostVotesForSubject = 0;
        }
    }
    
    function donateToCharity() public payable {
        exsecuteSubject();
        uint votes = msg.value.mul(10).div(1 ether);
        if(votes > 0) {
            if(members[msg.sender].votePower == 0) {
                totalMembers.add(1);
            }
            members[msg.sender].updateVotePower(votes);
        }
        
        if(totalMembers > 10) {
            contractStage = ContractStage.InAction;
        }
        
        LogDonation(msg.sender, msg.value);
    }
    
    function addSubject(address _recipientAddres, uint _requiredEther, bytes32 _title, bytes32 _description) public OnlyInActionStage OnlyMembers CanAddSubject{
        require(remainingSubjectsForAddThisWeek > 0);

        exsecuteSubject();
        
        remainingSubjectsForAddThisWeek = remainingSubjectsForAddThisWeek.sub(1);
        subjectsForApprovel.push(SubjectLib.Subject(_recipientAddres, 0, _requiredEther, now, _title, _description, ""));
        
        members[msg.sender].updateLastTimeAddedSubject();
        
        LogAddSubject(msg.sender, subjectsForApprovel.length.sub(1));
    }
    
    function voteForSubject(uint _index) public OnlyMembers OnlyValidSubject(_index) OnlyInActionStage {
        require(members[msg.sender].lastTimeVote.add(weekLength) < now);
        require(members[msg.sender].votePower > 0);
        exsecuteSubject();
        
        members[msg.sender].updateLastTimeVoteed();
        
        subjectsForApprovel[_index].updateSubjectVotes(members[msg.sender].votePower);
        
        updateMostVotedSubjectIndex(subjectsForApprovel[_index].votes, _index);
        
        LogVoteForSubject(msg.sender, _index);
    }
    
    function feedBackSubject(uint _index, bytes32 _feedback) public OnlyValidSubject(_index) {
        require(approvedSubjects[_index].recipientAddres == msg.sender);
        exsecuteSubject();
        
        approvedSubjects[_index].updateFeedback(_feedback);
        
        LogFeedBack(msg.sender, _index);
    }
    
    function voteForLocking() public OnlyMembers {
        exsecuteSubject();
        
        membersVotesForLock[msg.sender] = members[msg.sender].votePower;
        
        totalVotesForLock = totalVotesForLock.add(members[msg.sender].votePower);
        
        LogVoteForLocking(msg.sender);
        
        if(totalVotesForLock > totalMembers.div(2)){
            contractStage = ContractStage.Locked;
        }
    }
    
    function removeVoteForLocking() public OnlyMembers {
        require(membersVotesForLock[msg.sender] > 0);
        exsecuteSubject();
        
        totalVotesForLock = totalVotesForLock.sub(membersVotesForLock[msg.sender]);
        
        LogRemoveVoteForLocking(msg.sender);
        
        if(totalVotesForLock < totalMembers.div(2)){
            contractStage = ContractStage.InAction;
        }
    }
    
    function transferVotePower(address _addr) public OnlyMembers {
        uint votePower = members[msg.sender].votePower;
        members[msg.sender].deleteVotePower();
        members[_addr].updateVotePower(votePower);
        
        LogTransferVotePower(msg.sender, _addr, votePower);
    }
    
    function getAllSubjects(uint[] indexes) public view returns(uint[], uint[], uint[], bytes32[], bytes32[]) {
       uint[] memory votes = new uint[](indexes.length);
       uint[] memory requiredEther = new uint[](indexes.length);
       uint[] memory dateCreated = new uint[](indexes.length);
       
       bytes32[] memory title = new bytes32[](indexes.length);
       bytes32[] memory description = new bytes32[](indexes.length);
       
        for (uint i = 0; i < indexes.length; i++) {
            SubjectLib.Subject storage subject = subjectsForApprovel[indexes[i]];
            votes[i] = subject.votes;
            requiredEther[i] = subject.requiredEther;
            dateCreated[i] = subject.dateCreated;
            title[i] = subject.title;
            description[i] = subject.description;
        }
        
        return (votes,requiredEther,dateCreated, title, description);
    }
    
    function getAllApprovedSubjects(uint[] indexes) public view returns(uint[], uint[], uint[], bytes32[], bytes32[]) {
       uint[] memory votes = new uint[](indexes.length);
       uint[] memory requiredEther = new uint[](indexes.length);
       uint[] memory dateCreated = new uint[](indexes.length);
       
       bytes32[] memory title = new bytes32[](indexes.length);
       bytes32[] memory description = new bytes32[](indexes.length);
       
        for (uint i = 0; i < indexes.length; i++) {
            SubjectLib.Subject storage subject = approvedSubjects[indexes[i]];
            votes[i] = subject.votes;
            requiredEther[i] = subject.requiredEther;
            dateCreated[i] = subject.dateCreated;
            title[i] = subject.title;
            description[i] = subject.description;
        }
        
    }
    
    function getBalance() public view returns(uint){
        return this.balance;
    }
}