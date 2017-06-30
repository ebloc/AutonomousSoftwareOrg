# AutonomousSoftwareOrg
Smart Contract Based Autonomous Organization for Sustainable Software

## About
AutonomousSoftwareOrg is a Solidity smart contract that implements  an autonomous software organization to be used by software developers. 

### Connect to AutonomousSoftwareOrg Contract on our local Ethereum based blockchain : http://ebloc.cmpe.boun.edu.tr

```bash
address="0x692a70d2e424a56d2c6c27aa97d1a86395877b3a";
abi=[{"constant":true,"inputs":[],"name":"getSoftwareExecRecordLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"usedbysoftwareno","type":"uint256"}],"name":"getUsedBySoftware","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"members","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"propno","type":"uint256"}],"name":"VoteForProposal","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"title","type":"bytes32"},{"name":"url","type":"bytes32"},{"name":"prophash","type":"uint256"},{"name":"requestedfund","type":"uint256"},{"name":"deadline","type":"uint256"}],"name":"ProposeProposal","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"membersTryOut","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"addr","type":"address"}],"name":"UseBySoftware","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getDonationLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"citeno","type":"uint256"}],"name":"getCitation","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"softwareversion","type":"bytes32"},{"name":"url","type":"bytes32"},{"name":"inputhash","type":"uint256"},{"name":"outputhash","type":"uint256"}],"name":"addSoftwareExecRecord","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"url","type":"bytes32"}],"name":"BecomeMemberCandidate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getUsedBySoftwareLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"id","type":"uint32"}],"name":"getSoftwareVersionRecords","outputs":[{"name":"","type":"address"},{"name":"","type":"bytes32"},{"name":"","type":"bytes32"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"M","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"doinumber","type":"bytes32"}],"name":"Cite","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"donationno","type":"uint256"}],"name":"getDonationInfo","outputs":[{"name":"","type":"address"},{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getAutonomousSoftwareOrgInfo","outputs":[{"name":"","type":"bytes32"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"propno","type":"uint256"}],"name":"WithdrawProposalFund","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"memberno","type":"uint256"}],"name":"VoteMemberCandidate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"nummembers","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"memberno","type":"uint256"}],"name":"getMemberInfo","outputs":[{"name":"","type":"bytes32"},{"name":"","type":"address"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getMemberInfoLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"balance","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getProposalsLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"id","type":"uint32"}],"name":"getSoftwareExecRecord","outputs":[{"name":"","type":"address"},{"name":"","type":"bytes32"},{"name":"","type":"bytes32"},{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"propno","type":"uint256"}],"name":"getProposal","outputs":[{"name":"","type":"bytes32"},{"name":"","type":"bytes32"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"bool"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"url","type":"bytes32"},{"name":"version","type":"bytes32"},{"name":"sourcehash","type":"uint256"}],"name":"addSoftwareVersionRecord","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"N","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"softwarename","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"Donate","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[{"name":"memberno","type":"uint256"}],"name":"getCandidateMemberInfo","outputs":[{"name":"","type":"bytes32"},{"name":"","type":"address"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"geSoftwareVersionRecordsLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"memberno","type":"uint256"}],"name":"DelVoteMemberCandidate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getCitationLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"name","type":"bytes32"},{"name":"m","type":"uint8"},{"name":"n","type":"uint8"},{"name":"url","type":"bytes32"}],"payable":false,"type":"constructor"},{"payable":false,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"submitter","type":"address"},{"indexed":false,"name":"softwareversion","type":"bytes32"},{"indexed":false,"name":"url","type":"bytes32"},{"indexed":false,"name":"inputhash","type":"uint256"},{"indexed":false,"name":"outputhash","type":"uint256"}],"name":"LogSoftwareExecRecord","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"submitter","type":"address"},{"indexed":false,"name":"url","type":"bytes32"},{"indexed":false,"name":"version","type":"bytes32"},{"indexed":false,"name":"sourcehash","type":"uint256"}],"name":"LogSoftwareVersionRecord","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"propNo","type":"uint256"},{"indexed":false,"name":"title","type":"bytes32"},{"indexed":false,"name":"ipfsHash","type":"bytes32"},{"indexed":false,"name":"requestedFund","type":"uint256"},{"indexed":false,"name":"deadline","type":"uint256"}],"name":"LogPropose","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"votecount","type":"uint256"},{"indexed":false,"name":"blocknum","type":"uint256"},{"indexed":false,"name":"voter","type":"address"}],"name":"LogProposalVote","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"donor","type":"address"},{"indexed":false,"name":"amount","type":"uint256"},{"indexed":false,"name":"blknum","type":"uint256"}],"name":"LogDonation","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"propno","type":"uint256"},{"indexed":false,"name":"requestedfund","type":"uint256"},{"indexed":false,"name":"blocknum","type":"uint256"},{"indexed":false,"name":"proposalOwner","type":"address"}],"name":"LogWithdrawProposalFund","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"memberno","type":"uint256"},{"indexed":false,"name":"voter","type":"address"},{"indexed":false,"name":"votecount","type":"uint256"}],"name":"LogVoteMemberCandidate","type":"event"}]
var AutonomousSoftwareOrg = web3.eth.contract(abi).at(address);
```
