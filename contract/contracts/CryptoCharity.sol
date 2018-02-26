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
        string result;
    }
    
    struct Person {
        uint votePower;
        uint lastTimeVote;
    }
    
    mapping(address => Person) private members;
    
    uint public totalMembers;
    
    uint public lastTimeExecuteSubject;
    
    Subject[] private approvedSubjects;
    
    Subject[] private subjectsForApprovel;
    
    modifier OnlyMembers () {
        require(members[msg.sender].votePower > 0);
        _;
    }
    
    function donateToCharity() public payable {
        if((msg.value * 5) / 1 ether > 0) {
            if(members[msg.sender].votePower == 0) {
                totalMembers++;
            }
            members[msg.sender].votePower += (msg.value * 5) / 1 ether;
            
        }
    }
    
    function addSubject(address _recipientAddres, uint _requiredEther, string _title, string _description) public {
        subjectsForApprovel.push(Subject(_recipientAddres, 0, _requiredEther, now, _title, _description, ""));
    }
    
    function voteForSubject(uint index) public OnlyMembers {
        require(members[msg.sender].lastTimeVote + 7 days < now);
        require(subjectsForApprovel.length < index);
        
        members[msg.sender].lastTimeVote = now;
        
        subjectsForApprovel[index].votes += members[msg.sender].votePower;
    }
    
    function exsecuteSubjects(uint index) public {
        require(subjectsForApprovel.length < index);
        
        Subject memory sub = subjectsForApprovel[index];
        
        require(lastTimeExecuteSubject + 7 days < now);
        require(sub.votes >= totalMembers / 2);
        
        
        if(sub.requiredEther * 1 ether > getBalance()) {
            sub.recipientAddres.transfer(getBalance());
        }
        else {
            sub.recipientAddres.transfer(sub.requiredEther * 1 ether);
        }
        
        approvedSubjects.push(sub);
        
        delete subjectsForApprovel[index];
        
        for(uint i = 0; i < subjectsForApprovel.length; i++) {
            delete subjectsForApprovel[i];
        }
    }
    
    function getAllSubjects() public view returns(Subject[]) {
        return subjectsForApprovel;
    }
    
    function getAllApprovedSubjects() public view returns(Subject[]) {
        return approvedSubjects;
    }
    
    
    function getBalance() public view returns(uint) {
        return this.balance;
    }
}