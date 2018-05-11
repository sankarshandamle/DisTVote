pragma solidity ^0.4.0;

contract Vote {
    
    struct ManagerData {
        uint256 deposit;
        bytes32 EncryptionKey;
        bool exists;
    }
    
    //TimeSlots indexed as -> t_start, t_bcr, t_ecr, t_btd, t_etd, t_bvc, t_evc, t_bvt 
    uint256 [] TimeSlots;
    uint256 [] Candidates;
    bytes32 [] HelpValues;
    uint256 NoOfVoters;
    uint256 NoOfManagers;
    uint256 SecuirityAmt;
    bool TallyDone=false;
    mapping (address => ManagerData) Managers;
    
    //In this we are hashing the name of a voter to an int 
    bool [] T;
    address []  ManagerList;
    struct VoteCast {
        bool voted_cond;
        bytes32 voted;
    }
    
    mapping (uint256 => VoteCast) VoteBatch;
    
    struct Tokens {
        bytes32 encryption_id;
        uint256 help_value;
    }
    
    mapping (uint256 => Tokens) TokenBatch;
    
    function Vote (uint256 x, uint256 n_v, uint256 n_c) public {
        TimeSlots.push(now);
        SecuirityAmt=x;
        NoOfVoters=n_v;
        for (uint256 i=2; i<=TimeSlots.length;i++) {
            TimeSlots.push(TimeSlots[i-1]+10000);
        }
        for (i=1; i<=n_c; i++) {
            Candidates[i]=i;
        }
    }
   
    function AddToken (string s) {
        var temp = VoteBatch[uint256(keccak256(s))];
        temp.voted_cond=true;
    }
    
    //Managers are added if their deposit is greater than the required amount
    function DepositSecuirity (uint256 val) public {
        if(val > SecuirityAmt && now < TimeSlots[6]) {
            var manager=Managers[msg.sender];
            manager.deposit=val;
            manager.exists=true;
            ManagerList.push(msg.sender)-1;
        }
        NoOfManagers=ManagerList.length;
    }
    
    // Managers submit their encryption key
    function SubmitEncryptionKey (bytes32 s) public {
        if (Managers[msg.sender].exists && now < TimeSlots[6]) {
            Managers[msg.sender].EncryptionKey=s;
        }
        
    }
    
    //Give every candidate an EncryptionKey
    function GetEncryptionKey () public {
        if (now < TimeSlots[6] && now > TimeSlots[7]) {
            revert();
        }
        for (uint256 i=1; i<=NoOfVoters; i++) {
            var temp = TokenBatch[i];
            temp.encryption_id=Managers[ManagerList[i%NoOfManagers]].EncryptionKey;
            temp.help_value=Random_Generator();
            HelpValues.push(sha256(temp.help_value));
           // web3.sha3(web3.toHex(1));
        }
        
    }
    
    //Every candidate casts his vote
    function CastVote (string s, uint256 i, bytes32 ev) {
        if (now < TimeSlots[6] && now > TimeSlots[7]) {
            revert();
        }
        if (VoteBatch[uint256(keccak256(s))].voted_cond) {
            VoteBatch[uint256(keccak256(s))].voted_cond=false;
        }
        else {
            revert();
        }
        var temp = VoteBatch[uint256(keccak256(s))];
        temp.voted=ev;
    }

    //function to tally the votes
    function TallyVote (uint256 decrpty_vote) {
        if (now > TimeSlots[8]) {
            revert();
        }
        if (TallyDone==false) {
            for (uint256 i=1; i<=ManagerList.length; i++) {
                Candidates[decrpty_vote]+=1;
            }
        }
    }
    
    /* helper function to generate random number */
    function Random_Generator () returns (uint256) {
        uint256 random = now % 255;
        return random;
    }
    
}

