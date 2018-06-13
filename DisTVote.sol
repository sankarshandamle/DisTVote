pragma solidity ^0.4.0;

contract Vote {

    /* declaration */

    struct ManagerData {
        uint256 refundAmt;
        bytes32 EncryptionKey;
        bool exists;
    }

    uint256 [] TimeSlots;  //TimeSlots indexed as -> t_start, t_bcr, t_ecr, t_btd, t_etd, t_bvc, t_evc, t_bvt
    uint256 [] Candidates;
    bytes32 [] HelpValues; //not required for testing
    uint256 NoOfVoters;
    uint256 NoOfManagers;
    uint256 SecuirityAmt;
    uint256 KeyCount=0;
    bool TallyDone=false;
    mapping (address => ManagerData) Managers;


    bool [] T; //In this we are hashing the name of a voter to an int; not required
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

    /* methods */

    //setting up
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

    //Takes a string to generate a voter id i.e., Alice -> uint256
    function AddToken (string s) {
        var temp = VoteBatch[uint256(keccak256(s))];
        temp.voted_cond=true;
    }

    //Managers are added if their deposit is greater than the required amount
    function DepositSecuirity () public payable {
        require (msg.value > SecuirityAmt && now < TimeSlots[6] && Managers[msg.sender].exists==false);
        var manager=Managers[msg.sender];
        manager.refundAmt=msg.value-SecuirityAmt;
        manager.exists=true;
        ManagerList.push(msg.sender)-1;
        //reassign number of managers
        NoOfManagers=ManagerList.length;
    }

    // Managers submit their encryption key
    function SubmitEncryptionKey (bytes32 s) public {
        require(Managers[msg.sender].exists==true && now < TimeSlots[6]);
        Managers[msg.sender].EncryptionKey=s;
    }

    //Give every candidate an EncryptionKey; No of managers = no of Keys
    function GetEncryptionKey () public returns (uint256, bytes32) {
        require (now < TimeSlots[6] && now > TimeSlots[7]);
        uint256 temp = KeyCount;
        bytes32 enKey = Managers[ManagerList[temp]].EncryptionKey;
        KeyCount=(KeyCount+1)%NoOfManagers;
        return (temp,enKey);
    }

    //Every candidate casts his vote; s is the token eg. "Alice"
    function CastVote (string s, uint256 i, bytes32 ev) {
        require(now < TimeSlots[6] && now > TimeSlots[7]);
        var temp=VoteBatch[uint256(keccak256(s))];
        require (temp.voted_cond==true, "Token does not match");
        temp.voted_cond=false;
        temp.voted=ev;
    }

    //function to tally the votes; NoOfManagers is equal to the number of Keys
    //since Decryption will be done offline, just take the decrypted vote as a parameter for testing
    function VoteTally (uint256 decrypt_vote) {
        require(now > TimeSlots[8]);
        if (TallyDone==false) {
            for (uint256 i=1; i<=NoOfManagers; i++) {
                Candidates[decrypt_vote]+=1;
            }
        }
    }

    //pay the managers for their work
    function WithdrawReward() external payable  {
        require(Managers[msg.sender].exists==true && now > TimeSlots[7]);
        uint256 amt = Managers[msg.sender].refundAmt;
        Managers[msg.sender].refundAmt=0;
        if (amt > 0) {
          msg.sender.transfer(SecuirityAmt + amt);
        }

    }

    /* helper function to generate random number; not requried for testing */
    function Random_Generator () returns (uint256) {
        uint256 random = now % 255;
        return random;
    }

}
