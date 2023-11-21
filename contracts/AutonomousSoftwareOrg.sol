// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract AutonomousSoftwareOrg {
    struct SoftwareVersionRecord {
        address submitter;
        string url;
        string version;
        bytes32 sourceCodeHash;
    }

    struct SoftwareExecRecord {
        address submitter;
        string softwareVersion;
        string url;
        bytes32[] inputHash;
        bytes32[] outputHash;
    }

    struct MemberInfo {
        string url;
        address memberAddr;
        uint voteCount;
        mapping(address => bool) voted;
    }

    struct Proposal {
        string title;
        string url;
        uint256 propHash;
        address proposer;
        uint requestedFund;
        uint deadline;
        uint voteCount;
        bool withdrawn;
        mapping(address => bool) voted;
    }

    struct Donation {
        address donor;
        uint amnt;
        uint blkno;
    }

    string public softwareName;

    uint public balance;
    uint public numMembers;

    uint8 public M;
    uint8 public N;

    mapping(address => uint) public members;
    mapping(address => bool) public membersTryOut;

    mapping(bytes32 => uint) _hashToRoc;
    mapping(uint => bytes32) _rocToHash;

    SoftwareVersionRecord[] versions;
    SoftwareExecRecord[]  execRecords;

    MemberInfo[] membersInfo;
    Proposal[] proposals;
    Donation[] donations;
    bytes32[] citations;
    address[] usedBySoftware;

    event LogSoftwareExecRecord(address submitter, string softwareVersion, string url, bytes32[]  inputHash, bytes32[] outputHash);
    event LogSoftwareVersionRecord(address submitter, string url, string version, bytes32 sourceCodeHash);
    event LogPropose(uint propNo, string title, string url, uint requestedFund, uint deadline);
    event LogProposalVote(uint voteCount, uint blockNum, address voter);
    event LogDonation(address donor,uint amount,uint blknum);
    event LogWithdrawProposalFund(uint propNo, uint requestedFund, uint blockNum, address proposalOwner);
    event LogVoteMemberCandidate(uint memberNo,address voter,uint voteCount);
    event LogHashROC(address indexed provider, bytes32 hash, uint32 roc, bool isIPFS);

    modifier enough_fund_balance(uint propNo) {
        require(balance >= proposals[propNo].requestedFund);
        _;
    }

    modifier validProposalNo(uint propNo) {
        require(propNo < proposals.length);
        _;
    }

    modifier validMemberNo(uint memberNo) {
        require((memberNo!=0) && (memberNo <= membersInfo.length));
        _;
    }

    modifier member(address addr) {
        require( members[addr] != 0);
        _;
    }

    modifier notMember(address addr) {
        require( members[addr] == 0);
        _;
    }

    modifier validDeadline(uint deadline) {
        require(deadline >= block.number);
        _;
    }

    modifier withinDeadline(uint propNo) {
        require( proposals[propNo].deadline > block.number);
        _;
    }

    modifier notVotedForProposal(uint propNo) {
        require(! proposals[propNo].voted[msg.sender]);
        _;
    }

    modifier notVotedForMember(uint memberNo) {
        require(! membersInfo[memberNo-1].voted[msg.sender]);
        _;
    }

    modifier votedForMember(uint memberNo) {
        require(membersInfo[memberNo-1].voted[msg.sender]);
        _;
    }

    modifier  proposalOwner(uint propNo) {
        require(proposals[propNo].proposer == msg.sender);
        _;
    }


    modifier proposalMajority(uint propNo) {
        require((proposals[propNo].voteCount*N) >= (numMembers * M));
        _;
    }

    modifier membershipMajority(uint memberNo) {
        require((membersInfo[memberNo].voteCount*N) >= (numMembers * M));
        _;
    }

    modifier nonzeroPaymentMade() {
        require(msg.value > 0);
        _;
    }

    constructor(string memory name, uint8 m, uint8 n, string memory url) {
        if (m > n)
            revert();

        softwareName = name;
        MemberInfo storage _membersInfo = membersInfo.push();
        _membersInfo.url = url;
        _membersInfo.memberAddr = msg.sender;
        _membersInfo.voteCount = 0;
        members[msg.sender] = membersInfo.length;
        balance = 0;
        numMembers = 1;
        M = m;
        N = n;
    }

    function ProposeProposal(string memory title, string memory url, uint256 propHash, uint requestedFund, uint deadline) public
        member(msg.sender) validDeadline(deadline) {
        Proposal storage _proposal = proposals.push();
        _proposal.title = title;
        _proposal.url = url;
        _proposal.propHash = propHash;
        _proposal.proposer = msg.sender;
        _proposal.requestedFund = requestedFund;
        _proposal.deadline = deadline;
        _proposal.voteCount = 0;
        _proposal.withdrawn = false;
        emit LogPropose(proposals.length, title, url, requestedFund, deadline);
    }

    function VoteForProposal(uint propNo) public
        validProposalNo(propNo) withinDeadline(propNo)
        member(msg.sender) notVotedForProposal(propNo) {
        proposals[propNo].voted[msg.sender] = true;
        proposals[propNo].voteCount++;
        emit LogProposalVote(proposals[propNo].voteCount,block.number,msg.sender);
    }

    function WithdrawProposalFund(uint propNo)  public
        validProposalNo(propNo) withinDeadline(propNo)
        member(msg.sender) enough_fund_balance(propNo) proposalOwner(propNo)
        proposalMajority(propNo) {
        balance -=  proposals[propNo].requestedFund;
        if (proposals[propNo].withdrawn == true) {
            revert();
        }
        payable(msg.sender).transfer(proposals[propNo].requestedFund);
        proposals[propNo].withdrawn = true;
        emit LogWithdrawProposalFund(propNo,proposals[propNo].requestedFund,block.number,msg.sender);
    }

    function BecomeMemberCandidate(string memory url) public
        notMember(msg.sender) {
        if(membersTryOut[msg.sender] == true)
            revert();

        MemberInfo storage _memberInfo = membersInfo.push();
        _memberInfo.url = url;
        _memberInfo.memberAddr = msg.sender;
        _memberInfo.voteCount = 0;
        membersTryOut[msg.sender] = true;
    }

    function VoteMemberCandidate(uint memberNo) public validMemberNo(memberNo)
        member(msg.sender) notVotedForMember(memberNo) {
        membersInfo[memberNo-1].voted[msg.sender] = true;
        membersInfo[memberNo-1].voteCount++;

        if ((membersInfo[memberNo - 1].voteCount) * N >= (numMembers * M)) {
            if (members[membersInfo[memberNo - 1].memberAddr] == 0) {
                members[membersInfo[memberNo - 1].memberAddr] = memberNo;
                numMembers++;
            }
        }
        emit LogVoteMemberCandidate(memberNo - 1, msg.sender, membersInfo[memberNo - 1].voteCount);
    }

    function DelVoteMemberCandidate(uint memberNo) public
        validMemberNo(memberNo) member(msg.sender) votedForMember(memberNo) {
        membersInfo[memberNo-1].voted[msg.sender] = false;
        membersInfo[memberNo-1].voteCount--;
        if ((membersInfo[memberNo-1].voteCount * N) < (numMembers*M)) {
            if (members[membersInfo[memberNo-1].memberAddr] != 0) {
                delete(members[membersInfo[memberNo-1].memberAddr]);
                numMembers--;
            }
        }
    }

    function Donate() payable public
        nonzeroPaymentMade  {
        balance += msg.value;
        donations.push(Donation(msg.sender,msg.value,block.number));
        emit LogDonation(msg.sender, msg.value, block.number);

    }

    function Cite(bytes32 doiNumber) public  {
        citations.push(doiNumber);
    }

    function UseBySoftware(address addr) public {
        usedBySoftware.push(addr);
    }

    function addSoftwareExecRecord(string memory softwareVersion, string memory url, bytes32[] memory inputHash, bytes32[] memory outputHash)
        public member(msg.sender) {
        execRecords.push(SoftwareExecRecord(msg.sender, softwareVersion, url, inputHash, outputHash));
        emit LogSoftwareExecRecord(msg.sender, softwareVersion, url, inputHash, outputHash);
    }

    function addSoftwareVersionRecord(string memory url, string memory version, bytes32 sourceCodeHash)
        public {
        versions.push(SoftwareVersionRecord(msg.sender, url, version, sourceCodeHash));
        emit LogSoftwareVersionRecord(msg.sender, url, version, sourceCodeHash);
    }

    function getSoftwareExecRecord(uint32 id)
        public view returns(address, string memory, string memory, bytes32[] memory, bytes32[] memory) {
        return(execRecords[id].submitter,
               execRecords[id].softwareVersion,
               execRecords[id].url,
               execRecords[id].inputHash,
               execRecords[id].outputHash);
    }

    function getSoftwareExecRecordLength()
        public view returns (uint) {
        return(execRecords.length);
    }

    function getSoftwareVersionRecords(uint32 id)
        public view returns(address, string memory, string memory, bytes32) {
        return(versions[id].submitter,
               versions[id].url,
               versions[id].version,
               versions[id].sourceCodeHash);
    }

    function geSoftwareVersionRecordsLength()
        public view returns (uint) {
        return(versions.length);
    }

    function getAutonomousSoftwareOrgInfo()
        public view returns (string memory, uint, uint, uint, uint) {
        return (softwareName, balance, numMembers, M, N);
    }

    function getMemberInfoLength()
        public view returns (uint) {
        return(membersInfo.length);
    }

    function getMemberInfo(uint memberNo)
        member(membersInfo[memberNo-1].memberAddr)
        public view returns (string memory, address, uint) {
        return (membersInfo[memberNo - 1].url,
                membersInfo[memberNo - 1].memberAddr,
                membersInfo[memberNo - 1].voteCount);
    }

    function getCandidateMemberInfo(uint memberNo)
        notMember(membersInfo[memberNo - 1].memberAddr)
        public view returns (string memory, address, uint) {
        return (membersInfo[memberNo-1].url,
                membersInfo[memberNo-1].memberAddr,
                membersInfo[memberNo-1].voteCount);
    }

    function getProposalsLength()
        public view returns (uint) {
        return(proposals.length);
    }

    function getProposal(uint propNo)
        public view returns (string memory, string memory, uint256, uint, uint, bool, uint) {
        return (proposals[propNo].title,
                proposals[propNo].url,
                proposals[propNo].propHash,
                proposals[propNo].requestedFund,
                proposals[propNo].deadline,
                proposals[propNo].withdrawn,
                proposals[propNo].voteCount);
    }

    function getDonationLength()
        public view returns (uint) {
        return (donations.length);
    }

    function getDonationInfo(uint donationNo)
        public view returns (address, uint, uint) {
        return (donations[donationNo].donor,
                donations[donationNo].amnt,
                donations[donationNo].blkno);
    }

    function getCitationLength()
        public view returns (uint) {
        return (citations.length);
    }

    function getCitation(uint citeNo)
        public view returns (bytes32) {
        return (citations[citeNo]);
    }

    function getUsedBySoftwareLength()
        public view returns (uint) {
        return (usedBySoftware.length);
    }

    function getUsedBySoftware(uint usedBySoftwareNo)
        public view returns (address) {
        return (usedBySoftware[usedBySoftwareNo]);
    }

    // ------------------------------------------------------------------------------

    function hashToRoc(bytes32 hash, uint32 roc, bool isIPFS) public returns (bool) {
        if (_hashToRoc[hash] == 0) {
            _hashToRoc[hash] = roc;
            _rocToHash[roc] = hash;
            emit LogHashROC(msg.sender, hash, roc, isIPFS);
        }
        return true;
    }
}
