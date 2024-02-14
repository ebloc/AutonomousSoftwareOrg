// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./eBlocBroker.sol";
import "./ResearchCertificate.sol";

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
        bytes32 propHash;
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

    mapping(bytes32 => mapping(uint32 => uint256[])) incoming;
    mapping(bytes32 => mapping(uint32 => uint256[])) outgoing;

    mapping(bytes32 => mapping(uint32 => uint)) incomingLen;
    mapping(bytes32 => mapping(uint32 => uint)) outgoingLen;

    mapping(bytes32 => string) versionRecord;
    mapping(bytes32 => mapping(string => string)) nameRecord;

    uint32 softwareExecutionNumber;
    uint32 globalIndexCounter;
    address[] softwareExecutionRecordOwner;

    SoftwareVersionRecord[] versionRecords;

    MemberInfo[] membersInfo;
    Proposal[] proposals;
    Donation[] donations;
    bytes32[] citations;
    address[] usedBySoftware;

    address public eBlocBrokerAddress;
    address public ResearchCertificateAddress;

    event LogSoftwareExecRecord(address indexed submitter, bytes32 indexed sourceCodeHash, uint32 index, bytes32[]  inputHash, bytes32[] outputHash);
    event LogSoftwareVersionRecord(address submitter, string url, string version, bytes32 sourceCodeHash);
    event LogPropose(uint propNo, string title, string url, uint requestedFund, uint deadline);
    event LogProposalVote(uint voteCount, uint blockNum, address voter);
    event LogDonation(address donor,uint amount,uint blknum);
    event LogWithdrawProposalFund(uint propNo, uint requestedFund, uint blockNum, address proposalOwner);
    event LogVoteMemberCandidate(uint memberNo,address voter,uint voteCount);
    event LogHashROC(address indexed provider, bytes32 hash, uint roc, bool isIPFS);
    event LogSoftwareNameVersion(address indexed provider, bytes32 sourceCodeHash, string name, string version);

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
        require(members[addr] != 0);
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
        require(proposals[propNo].deadline > block.number);
        _;
    }

    modifier notVotedForProposal(uint propNo) {
        require(! proposals[propNo].voted[msg.sender]);
        _;
    }

    modifier notVotedForMember(uint memberNo) {
        require(! membersInfo[memberNo - 1].voted[msg.sender]);
        _;
    }

    modifier votedForMember(uint memberNo) {
        require(membersInfo[memberNo - 1].voted[msg.sender]);
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

    modifier validEblocBrokerProvider() {
        require(eBlocBroker(eBlocBrokerAddress).doesProviderExist(msg.sender));
        _;
    }


    modifier softwareExecutionRecordOwnerCheck(uint index) {
        require(softwareExecutionRecordOwner[index] == msg.sender);
        _;
    }

    constructor(string memory name, uint8 m, uint8 n, string memory url, address _eBlocBrokerAddress, address _ResearchCertificateAddress) {
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

        softwareExecutionRecordOwner.push(msg.sender); // dummy address
        eBlocBrokerAddress = _eBlocBrokerAddress;
        ResearchCertificateAddress = _ResearchCertificateAddress;
    }

    function ProposeProposal(string memory title, string memory url, bytes32 propHash, uint requestedFund, uint deadline) public
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
        membersInfo[memberNo - 1].voted[msg.sender] = true;
        membersInfo[memberNo - 1].voteCount++;
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
        membersInfo[memberNo - 1].voted[msg.sender] = false;
        membersInfo[memberNo - 1].voteCount--;
        if ((membersInfo[memberNo - 1].voteCount * N) < (numMembers*M)) {
            if (members[membersInfo[memberNo - 1].memberAddr] != 0) {
                delete(members[membersInfo[memberNo - 1].memberAddr]);
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

    function UsedBySoftware(address addr) public {
        usedBySoftware.push(addr);
    }

    function setNextCounter(bytes32 sourceCodeHash) public member(msg.sender) validEblocBrokerProvider() returns (uint32) {
        globalIndexCounter += 1;
        softwareExecutionRecordOwner.push(msg.sender);
        return globalIndexCounter;
    }

    function getSoftwareExecutionCounter() public view returns(uint32) {
        return softwareExecutionNumber;
    }

    function addSoftwareExecRecord(bytes32 sourceCodeHash, uint32 index, bytes32[] memory inputHash, bytes32[] memory outputHash)
        public member(msg.sender) validEblocBrokerProvider() returns (uint32) {

        if (index == 0) {
            globalIndexCounter += 1;
            softwareExecutionRecordOwner.push(msg.sender);
            index = globalIndexCounter;
        }
        else {
            require(softwareExecutionRecordOwner[index] == msg.sender);
        }

        softwareExecutionNumber += 1;
        ResearchCertificate(ResearchCertificateAddress).createCertificate(msg.sender, sourceCodeHash);
        //
        for (uint256 i = 0; i < inputHash.length; i++) {
            uint256 tokenIndex = ResearchCertificate(ResearchCertificateAddress).createCertificate(msg.sender, inputHash[i]);
            incoming[sourceCodeHash][index].push(tokenIndex);
        }
        incomingLen[sourceCodeHash][index] = incomingLen[sourceCodeHash][index] + inputHash.length;
        //
        for (uint256 i = 0; i < outputHash.length; i++) {
            uint256 tokenIndex = ResearchCertificate(ResearchCertificateAddress).createCertificate(msg.sender, outputHash[i]);
            outgoing[sourceCodeHash][index].push(tokenIndex);
        }
        outgoingLen[sourceCodeHash][index] = outgoingLen[sourceCodeHash][index] + outputHash.length;
        emit LogSoftwareExecRecord(msg.sender, sourceCodeHash, index, inputHash, outputHash);
        return index;
    }

    function delSoftwareExecRecord(bytes32 sourceCodeHash, uint32 index) public member(msg.sender) softwareExecutionRecordOwnerCheck(index) {
        require(incoming[sourceCodeHash][index][0] > 0 || incoming[sourceCodeHash][index][0] > 0);
        delete incoming[sourceCodeHash][index];
        delete outgoing[sourceCodeHash][index];
        delete incomingLen[sourceCodeHash][index];
        delete outgoingLen[sourceCodeHash][index];
        softwareExecutionRecordOwner[index] = address(0);
        softwareExecutionNumber -= 1;
    }

    function getSoftwareVersion(bytes32 sourceCodeHash) public view returns(string memory) {
        return versionRecord[sourceCodeHash];
    }

    function getSoftwareName(bytes32 sourceCodeHash, string memory version) public view returns(string memory) {
        return nameRecord[sourceCodeHash][version];
    }

    function setSoftwareNameVersion(bytes32 sourceCodeHash,  string memory name, string memory version)
        public member(msg.sender) validEblocBrokerProvider() {
        versionRecord[sourceCodeHash] = version;
        nameRecord[sourceCodeHash][version] = name;
        emit LogSoftwareNameVersion(msg.sender, sourceCodeHash, name, version);
    }

    function getNoOfIncomingDataArcs(bytes32 sourceCodeHash, uint32 index) public view returns(uint) {
        return incomingLen[sourceCodeHash][index];
    }

    function getNoOfOutgoingDataArcs(bytes32 sourceCodeHash, uint32 index) public view returns(uint) {
        return outgoingLen[sourceCodeHash][index];
    }

    function getIncomingData(bytes32 sourceCodeHash, uint32 index, uint i) public view returns(uint) {
        return incoming[sourceCodeHash][index][i];
    }

    function getOutgoingData(bytes32 sourceCodeHash, uint32 index, uint i) public view returns(uint) {
        return outgoing[sourceCodeHash][index][i];
    }

    ///////////////////////////////////////////////////////////////////////
    function addSoftwareVersionRecord(string memory url, bytes32 sourceCodeHash, string memory version)
        public {
        require(eBlocBroker(eBlocBrokerAddress).doesProviderExist(msg.sender));
        versionRecords.push(SoftwareVersionRecord(msg.sender, url, version, sourceCodeHash));
        emit LogSoftwareVersionRecord(msg.sender, url, version, sourceCodeHash);
    }

    function getSoftwareVersionRecords(uint32 id)
        public view returns(address, string memory, string memory, bytes32) {
        return(versionRecords[id].submitter,
               versionRecords[id].url,
               versionRecords[id].version,
               versionRecords[id].sourceCodeHash);
    }

    function getSoftwareVersionRecordsLength()
        public view returns (uint) {
        return(versionRecords.length);
    }
    ///////////////////////////////////////////////////////////////////////

    function getAutonomousSoftwareOrgInfo()
        public view returns (string memory, uint, uint, uint, uint) {
        return (softwareName, weiBalance, numMembers, M, N);
    }

    function getMemberInfoLength()
        public view returns (uint) {
        return(membersInfo.length);
    }

    function getMemberInfo(uint memberNo)
        member(membersInfo[memberNo - 1].memberAddr)
        public view returns (string memory, address, uint) {
        return (membersInfo[memberNo - 1].url,
                membersInfo[memberNo - 1].memberAddr,
                membersInfo[memberNo - 1].voteCount);
    }

    function getCandidateMemberInfo(uint memberNo)
        notMember(membersInfo[memberNo - 1].memberAddr)
        public view returns (string memory, address, uint) {
        return (membersInfo[memberNo - 1].url,
                membersInfo[memberNo - 1].memberAddr,
                membersInfo[memberNo - 1].voteCount);
    }

    function getProposalsLength()
        public view returns (uint) {
        return(proposals.length);
    }

    function getProposal(uint propNo)
        public view returns (string memory, string memory, bytes32, uint, uint, bool, uint) {
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

}
