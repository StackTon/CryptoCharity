pragma solidity ^0.4.20;

contract CryptoCharity {
    
    enum ContractStage {Starting, InAction}
    
    struct Subject {
        address recipientAddres;
        uint votes;
        uint requiredEther;
        uint dateCreated;
        string title;
        string description;
        string feedback;
    }
    
    struct Person {
        uint votePower;
        uint lastTimeVote;
    }
    
    mapping(address => Person) private members;
    
    uint public totalMembers;
    
    uint public lastTimeExecuteSubject;
    
    uint public currentWeekTime;
    
    Subject[] private approvedSubjects;
    
    Subject[] private subjectsForApprovel;
    
    modifier OnlyMembers () {
        require(members[msg.sender].votePower > 0);
        _;
    }
    
    modifier IsSubjectValid(uint index) {
        require(subjectsForApprovel.length < index);
        require(subjectsForApprovel[index].dateCreated + 7 days > now);
        _;
    }
    
    function CryptoCharity() public {
        currentWeekTime = now;
    }
    
    function donateToCharity() public payable {
        if((msg.value * 10) / 1 ether > 0) {
            if(members[msg.sender].votePower == 0) {
                totalMembers++;
            }
            members[msg.sender].votePower += (msg.value * 10) / 1 ether;
            
        }
    }
    
    function addSubject(address _recipientAddres, uint _requiredEther, string _title, string _description) public {
        subjectsForApprovel.push(Subject(_recipientAddres, 0, _requiredEther, now, _title, _description, ""));
    }
    
    function voteForSubject(uint index) public OnlyMembers IsSubjectValid(index) {
        require(members[msg.sender].lastTimeVote + 7 days < now);
        require(members[msg.sender].votePower > 0);
        
        members[msg.sender].lastTimeVote = now;
        
        subjectsForApprovel[index].votes += members[msg.sender].votePower;
    }
    
    function exsecuteSubjects(uint index) public IsSubjectValid(index) {
        require(lastTimeExecuteSubject + 7 days < now);
        
        Subject memory sub = subjectsForApprovel[index];
        
        if(sub.votes >= totalMembers / 2){
            if(sub.requiredEther * 1 ether > getBalance()){
                sub.recipientAddres.transfer(getBalance());
            }
            else {
                sub.recipientAddres.transfer(sub.requiredEther * 1 ether);
            }
            
            approvedSubjects.push(sub);
        }
        currentWeekTime = now;
    }
    
    
    function feedBackSubject(uint _index, string _string) public {
        require(approvedSubjects[_index].recipientAddres == msg.sender);
        
        approvedSubjects[_index].feedback = _string;
    }
    
    function getAllSubjects() public view returns(Subject[]) {
        return subjectsForApprovel;
    }
    
    function getAllApprovedSubjects() public view returns(Subject[]) {
        return approvedSubjects;
    }
    
    
    function getBalance() public view returns(uint){
        return this.balance;
    }
}