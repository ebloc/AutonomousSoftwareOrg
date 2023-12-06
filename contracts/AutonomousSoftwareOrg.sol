// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./eBlocBroker.sol";

contract AutonomousSoftwareOrg {
    struct SoftwareVersionRecord {
        address submitter;
        string url;
        string version;
        bytes32 sourceCodeHash;
    }

    struct SoftwareExecRecord {
        address submitter;
        bytes32 sourceCodeHash;
        uint32 index;
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

    uint public weiBalance;
    uint public numMembers;

    uint8 public M;
    uint8 public N;

    mapping(address => uint) public members;
    mapping(address => bool) public membersTryOut;

    mapping(bytes32 => uint) _hashToRoc;
    mapping(uint => bytes32) _rocToHash;

    mapping(bytes32 => mapping(uint32 => bytes32[])) incoming;
    mapping(bytes32 => mapping(uint32 => bytes32[])) outgoing;

    mapping(bytes32 => mapping(uint32 => uint)) incomingLen;
    mapping(bytes32 => mapping(uint32 => uint)) outgoingLen;

    SoftwareVersionRecord[] versions;
    SoftwareExecRecord[]  execRecords;

    MemberInfo[] membersInfo;
    Proposal[] proposals;
    Donation[] donations;
    bytes32[] citations;
    address[] usedBySoftware;

    address public eBlocBrokerAddress;

    event LogSoftwareExecRecord(address indexed submitter, bytes32 indexed sourceCodeHash, uint32 index, bytes32[]  inputHash, bytes32[] outputHash);
    event LogSoftwareVersionRecord(address submitter, string url, string version, bytes32 sourceCodeHash);
    event LogPropose(uint propNo, string title, string url, uint requestedFund, uint deadline);
    event LogProposalVote(uint voteCount, uint blockNum, address voter);
    event LogDonation(address donor,uint amount,uint blknum);
    event LogWithdrawProposalFund(uint propNo, uint requestedFund, uint blockNum, address proposalOwner);
    event LogVoteMemberCandidate(uint memberNo,address voter,uint voteCount);
    event LogHashROC(address indexed provider, bytes32 hash, uint roc, bool isIPFS);

    modifier enough_fund_balance(uint propNo) {
        require(weiBalance >= proposals[propNo].requestedFund);
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

    constructor(string memory name, uint8 m, uint8 n, string memory url, address _eBlocBrokerAddress) {
        if (m > n)
            revert();

        softwareName = name;
        MemberInfo storage _membersInfo = membersInfo.push();
        _membersInfo.url = url;
        _membersInfo.memberAddr = msg.sender;
        _membersInfo.voteCount = 0;
        members[msg.sender] = membersInfo.length;
        weiBalance = 0;
        numMembers = 1;
        M = m;
        N = n;

        eBlocBrokerAddress = _eBlocBrokerAddress;
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
        weiBalance -=  proposals[propNo].requestedFund;
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
        weiBalance += msg.value;
        donations.push(Donation(msg.sender,msg.value,block.number));
        emit LogDonation(msg.sender, msg.value, block.number);

    }

    function Cite(bytes32 doiNumber) public  {
        citations.push(doiNumber);
    }

    function UseBySoftware(address addr) public {
        usedBySoftware.push(addr);
    }

    function addSoftwareExecRecord(bytes32 sourceCodeHash, uint32 index, bytes32[] memory inputHash, bytes32[] memory outputHash)
        public member(msg.sender) {
        require(eBlocBroker(eBlocBrokerAddress).doesProviderExist(msg.sender));
        for (uint256 i = 0; i < inputHash.length; i++) {
            incoming[sourceCodeHash][index].push(inputHash[i]);
        }
        incomingLen[sourceCodeHash][index] = incomingLen[sourceCodeHash][index] + inputHash.length;
        for (uint256 i = 0; i < outputHash.length; i++) {
            outgoing[sourceCodeHash][index].push(outputHash[i]);
        }
        outgoingLen[sourceCodeHash][index] = outgoingLen[sourceCodeHash][index] + outputHash.length;
        emit LogSoftwareExecRecord(msg.sender, sourceCodeHash, index, inputHash, outputHash);
    }

    function delSoftwareExecRecord(bytes32 sourceCodeHash, uint32 index) public {
        delete incoming[sourceCodeHash][index];
        delete outgoing[sourceCodeHash][index];
        delete incomingLen[sourceCodeHash][index];
        delete outgoingLen[sourceCodeHash][index];
    }

    function getIncomingLen(bytes32 sourceCodeHash, uint32 index) public view returns(uint) {
        return incomingLen[sourceCodeHash][index];
    }

    function getOutgoingLen(bytes32 sourceCodeHash, uint32 index) public view returns(uint) {
        return outgoingLen[sourceCodeHash][index];
    }

    function getIncoming(bytes32 sourceCodeHash, uint32 index, uint i) public view returns(bytes32) {
        return incoming[sourceCodeHash][index][i];
    }

    function getOutgoing(bytes32 sourceCodeHash, uint32 index, uint i) public view returns(bytes32) {
        return outgoing[sourceCodeHash][index][i];
    }

    /* function getIncomings(bytes32 sourceCodeHash, uint32 index) public view returns(bytes32[] memory) { */
    /*     return incoming[sourceCodeHash][index]; */
    /* } */

    /* function getOutgoings(bytes32 sourceCodeHash, uint32 index) public view returns(bytes32[] memory) { */
    /*     return outgoing[sourceCodeHash][index]; */
    /* } */

    function addSoftwareVersionRecord(string memory url, string memory version, bytes32 sourceCodeHash)
        public {
        versions.push(SoftwareVersionRecord(msg.sender, url, version, sourceCodeHash));
        emit LogSoftwareVersionRecord(msg.sender, url, version, sourceCodeHash);
    }

    function getSoftwareExecRecord(uint32 id)
        public view returns(address, bytes32, uint32, bytes32[] memory, bytes32[] memory) {
        return(execRecords[id].submitter,
               execRecords[id].sourceCodeHash,
               execRecords[id].index,
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
        return (softwareName, weiBalance, numMembers, M, N);
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

    function hashToRoc(bytes32 hash, uint roc, bool isIPFS) public returns (bool) {
        if (_hashToRoc[hash] == 0) {
            _hashToRoc[hash] = roc;
            _rocToHash[roc] = hash;
            emit LogHashROC(msg.sender, hash, roc, isIPFS);
        }
        return true;
    }

    function getFromHashToRoc(bytes32 hash) public view returns (uint) {
        return _hashToRoc[hash];
    }

    function getFromRocToHash(uint roc) public view returns (bytes32) {
        return _rocToHash[roc];
    }

}
