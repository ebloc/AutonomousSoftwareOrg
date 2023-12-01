#!/usr/bin/env python3


def _test_AutonomousSoftwareOrg(web3, accounts, chain):
    print(accounts)
    autonomousSoftwareOrg, _ = chain.provider.get_or_deploy_contract(
        "AutonomousSoftwareOrg"
    )

    tx = autonomousSoftwareOrg.transact().AutonomousSoftwareOrg("alper", 2, 3, "0x")
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[0]
    (
        softwarename,
        balance,
        nummembers,
        M,
        N,
    ) = autonomousSoftwareOrg.call().getAutonomousSoftwareOrgInfo()
    print(
        "name: "
        + softwarename
        + " |balance: "
        + str(balance)
        + " |numMembers: "
        + str(nummembers)
        + " |M: "
        + str(M)
        + " |N:"
        + str(N)
    )

    web3.eth.defaultAccount = accounts[1]
    tx = autonomousSoftwareOrg.transact().BecomeMemberCandidate("0x")  # memNo:1
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[2]
    tx = autonomousSoftwareOrg.transact().BecomeMemberCandidate("0x")  # memNo:2
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[3]
    tx = autonomousSoftwareOrg.transact().BecomeMemberCandidate("0x")  # memNo:3
    contract_address = chain.wait.for_receipt(tx)

    memberInfoLength = autonomousSoftwareOrg.call().getMemberInfoLength()
    print(memberInfoLength)

    web3.eth.defaultAccount = accounts[0]
    url, memberaddr, votecount = autonomousSoftwareOrg.call().getCandidateMemberInfo(3)
    print(url + "|" + memberaddr)

    web3.eth.defaultAccount = accounts[0]
    # 0 => 1
    tx = autonomousSoftwareOrg.transact().VoteMemberCandidate(2)
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[1]
    # 1 => 2
    tx = autonomousSoftwareOrg.transact().VoteMemberCandidate(3)
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[0]
    # 0 => 2
    tx = autonomousSoftwareOrg.transact().VoteMemberCandidate(3)
    contract_address = chain.wait.for_receipt(tx)

    # Member-2 became valid member
    web3.eth.defaultAccount = accounts[0]
    url, memberaddr, votecount = autonomousSoftwareOrg.call().getMemberInfo(2)
    print(url + "|" + memberaddr + "|" + str(votecount))
    (
        softwarename,
        balance,
        nummembers,
        M,
        N,
    ) = autonomousSoftwareOrg.call().getAutonomousSoftwareOrgInfo()
    print(
        "name: "
        + softwarename
        + " |balance: "
        + str(balance)
        + " |numMembers: "
        + str(nummembers)
        + " |M: "
        + str(M)
        + " |N:"
        + str(N)
    )

    web3.eth.defaultAccount = accounts[2]
    url, memberaddr, votecount = autonomousSoftwareOrg.call().getMemberInfo(2)
    print(url + "|" + memberaddr + "|vv" + str(votecount))

    web3.eth.defaultAccount = accounts[0]
    tx = autonomousSoftwareOrg.transact().DelVoteMemberCandidate(3)
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[0]
    # 0 => 3 memNo:3 votes
    tx = autonomousSoftwareOrg.transact().VoteMemberCandidate(3)
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[2]
    url, memberaddr, votecount = autonomousSoftwareOrg.call().getMemberInfo(2)
    print(url + "|" + memberaddr)

    (
        softwarename,
        balance,
        nummembers,
        M,
        N,
    ) = autonomousSoftwareOrg.call().getAutonomousSoftwareOrgInfo()
    print(
        "name: "
        + softwarename
        + " |balance: "
        + str(balance)
        + " |numMembers: "
        + str(nummembers)
        + " |M: "
        + str(M)
        + " |N:"
        + str(N)
    )

    set_txn_hash = autonomousSoftwareOrg.transact(
        {"from": accounts[5], "value": web3.toWei(2, "wei")}
    ).Donate()
    contract_address = chain.wait.for_receipt(tx)

    set_txn_hash = autonomousSoftwareOrg.transact(
        {"from": accounts[6], "value": web3.toWei(2, "wei")}
    ).Donate()
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[2]
    set_txn_hash = autonomousSoftwareOrg.transact().ProposeProposal(
        "Prop0", "0x", 0, 4, 14
    )
    contract_address = chain.wait.for_receipt(tx)

    (
        title,
        url,
        prophash,
        requestedfund,
        deadline,
        withdrawn,
        votecount,
    ) = autonomousSoftwareOrg.call().getProposal(0)
    print(
        title
        + "|"
        + url
        + "|"
        + str(requestedfund)
        + " "
        + str(deadline)
        + " "
        + str(withdrawn)
    )

    web3.eth.defaultAccount = accounts[0]
    # vote 1
    set_txn_hash = autonomousSoftwareOrg.transact().VoteForProposal(0)
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[1]
    set_txn_hash = autonomousSoftwareOrg.transact().VoteForProposal(0)
    contract_address = chain.wait.for_receipt(tx)

    web3.eth.defaultAccount = accounts[2]
    # vote 2
    set_txn_hash = autonomousSoftwareOrg.transact().WithdrawProposalFund(0)
    # fails not enough vote.
    contract_address = chain.wait.for_receipt(tx)

    (
        title,
        url,
        prophash,
        requestedfund,
        deadline,
        withdrawn,
        votecount,
    ) = autonomousSoftwareOrg.call().getProposal(0)
    print(
        title
        + "|"
        + url
        + "|"
        + str(requestedfund)
        + " "
        + str(deadline)
        + " "
        + str(withdrawn)
    )

    # web3.eth.defaultAccount = accounts[0];
    # set_txn_hash     = autonomousSoftwareOrg.transact().WithdrawProposalFund(0); # fails not enough vote
    # contract_address = chain.wait.for_receipt(tx)
