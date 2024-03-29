#!/usr/bin/python3

import atexit
from broker._utils._log import log
import brownie
import pytest
import random
from broker.eblocbroker_scripts.utils import Cent

auto = None
ebb = None
roc = None

gas_costs = {}


def print_gas_costs():
    log("average_gas_costs=", end="")
    gas_costs_items_temp = {}
    for k, v in gas_costs.items():
        if v:
            gas_costs_items_temp[k] = int(sum(v) / len(v))

    log(dict(gas_costs_items_temp))


@pytest.fixture(scope="session", autouse=True)
def cleanup():
    print_gas_costs()


@pytest.fixture(scope="module", autouse=True)
def my_own_session_run_at_beginning(_Auto, _Ebb, _Roc):
    global auto  # type: ignore
    global ebb  # type: ignore
    global roc
    auto = _Auto
    ebb = _Ebb
    roc = _Roc


def md5_hash():
    _hash = random.getrandbits(128)
    return "%032x" % _hash


def append_gas_cost(func_n, tx):
    if func_n not in gas_costs:
        gas_costs[func_n] = []

    gas_costs[func_n].append(tx.__dict__["gas_used"])


def test_paper(web3, accounts):
    print(auto.getAutonomousSoftwareOrgInfo())
    tx = auto.BecomeMemberCandidate("0x", {"from": accounts[1]})
    append_gas_cost("BecomeMemberCandidate", tx)
    auto.BecomeMemberCandidate("0x", {"from": accounts[2]})
    auto.BecomeMemberCandidate("0x", {"from": accounts[3]})
    assert auto.getMemberInfoLength() == 4
    log(auto.getCandidateMemberInfo(3))
    tx = auto.VoteMemberCandidate(2, {"from": accounts[0]})
    append_gas_cost("VoteMemberCandidate", tx)
    auto.VoteMemberCandidate(3, {"from": accounts[1]})
    auto.VoteMemberCandidate(3, {"from": accounts[0]})
    log(auto.getMemberInfo(2, {"from": accounts[0]}))
    log(auto.getAutonomousSoftwareOrgInfo())
    log(auto.getMemberInfo(2, {"from": accounts[2]}))
    tx = auto.DelVoteMemberCandidate(3, {"from": accounts[0]})
    append_gas_cost("DelVoteMemberCandidate", tx)
    auto.VoteMemberCandidate(3, {"from": accounts[0]})
    log(auto.getMemberInfo(2, {"from": accounts[2]}))
    log(auto.getAutonomousSoftwareOrgInfo())
    tx = auto.Donate({"from": accounts[5], "value": web3.toWei(2, "wei")})
    append_gas_cost("Donate", tx)
    auto.Donate({"from": accounts[6], "value": web3.toWei(2, "wei")})
    blockNum = web3.eth.blockNumber
    tx = auto.ProposeProposal(
        "Prop0", "1.0.0", "0x", 4, blockNum + 30, {"from": accounts[2]}
    )
    append_gas_cost("ProposeProposal", tx)
    log(auto.getProposal(0))
    tx = auto.VoteForProposal(0, {"from": accounts[0]})
    append_gas_cost("VoteForProposal", tx)
    auto.VoteForProposal(0, {"from": accounts[1]})
    tx = auto.WithdrawProposalFund(0, {"from": accounts[2]})
    append_gas_cost("WithdrawProposalFund", tx)
    log(auto.getProposal(0))
    with brownie.reverts():
        #: fails there is not enough vote
        tx = auto.WithdrawProposalFund(0, {"from": accounts[0]})
        append_gas_cost("WithdrawProposalFund", tx)

    tx = auto.Cite(str.encode("10.1016/j.arabjc.2017.05.011"))
    append_gas_cost("Cite", tx)

    tx = auto.UsedBySoftware(accounts[0])
    append_gas_cost("UsedBySoftware", tx)


def test_AutonomousSoftwareOrg(accounts):
    se = md5_hash()
    input_hash = [md5_hash(), "0xabcd"]
    output_hash = [md5_hash(), "0xabcde"]
    with brownie.reverts():
        index = 0
        auto.addSoftwareExecRecord(
            se, index, input_hash, output_hash, {"from": accounts[0]}
        )

    input_hash = [md5_hash(), md5_hash(), md5_hash()]
    output_hash = [md5_hash(), md5_hash(), md5_hash()]
    with brownie.reverts():
        index = 0
        auto.addSoftwareExecRecord(
            se, index, input_hash, output_hash, {"from": accounts[0]}
        )

    GPG_FINGERPRINT = "0359190A05DF2B72729344221D522F92EFA2F330"
    provider_gmail = "provider_test@gmail.com"
    fid = "ee14ea28-b869-1036-8080-9dbd8c6b1579@b2drop.eudat.eu"
    ipfs_address = "/ip4/79.123.177.145/tcp/4001/ipfs/QmWmZQnb8xh3gHf9ZFmVQC4mLEav3Uht5kHJxZtixG3rsf"
    price_core_min = Cent("1 cent")
    price_data_transfer_mb = Cent("1 cent")
    price_storage_hr = Cent("1 cent")
    price_cache_mb = Cent("1 cent")
    prices = [price_core_min, price_data_transfer_mb, price_storage_hr, price_cache_mb]
    available_core = 8
    commitment_bn = 600
    tx = ebb.registerProvider(
        GPG_FINGERPRINT,
        provider_gmail,
        fid,
        ipfs_address,
        available_core,
        prices,
        commitment_bn,
        {"from": accounts[0]},
    )
    tx = auto.setNextExecutionCounter(se)
    append_gas_cost("setNextExecutionCounter", tx)
    index = return_value = tx.return_value
    with brownie.reverts():
        auto.delSoftwareExecRecord(se, index)

    input_hash = [md5_hash(), "0xabcd"]
    output_hash = [md5_hash(), "0xabcde", md5_hash()]
    tx = auto.addSoftwareExecRecord(
        se, index, input_hash, output_hash, {"from": accounts[0]}
    )

    input_hash = [md5_hash(), "0xabcd"]
    output_hash = [md5_hash(), "0xabcde", md5_hash()]
    tx = auto.addSoftwareExecRecord(
        se, 0, input_hash, output_hash, {"from": accounts[0]}
    )

    tx = auto.setSoftwareNameVersion(se, "matlab", "v1.0.0")
    append_gas_cost("setSoftwareNameVersion", tx)
    assert tx.events["LogSoftwareNameVersion"]["name"] == "matlab"
    assert tx.events["LogSoftwareNameVersion"]["version"] == "v1.0.0"
    assert auto.getSoftwareName(se, auto.getSoftwareVersion(se)) == "matlab"

    assert auto.getSoftwareExecutionCounter() == 2

    auto.delSoftwareExecRecord(se, index)
    with brownie.reverts():
        auto.delSoftwareExecRecord(se, index)

    assert auto.getSoftwareExecutionCounter() == 1
    # ----------------------------------------------------------------------
    input_hash_1 = [output_hash[0], output_hash[1]]
    output_hash_1 = [md5_hash()]
    se_2 = md5_hash()
    tx = auto.addSoftwareExecRecord(
        se_2, 0, input_hash_1, output_hash_1, {"from": accounts[0]}
    )
    assert auto.getSoftwareExecutionCounter() == 2
    assert tx.return_value == 3
    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    log()
    jobs = [f"{se}_{index}", f"{se_2}_{index}"]
    counter = 1
    nodes = {}
    for job in jobs:
        output = job.split("_")
        _se = output[0]
        _index = output[1]
        nodes[counter] = job
        counter += 1
        output = []
        for i in range(auto.getNoOfIncomingDataArcs(_se, _index)):
            output.append(auto.getIncomingData(_se, _index, i))

        for h in output:
            try:
                [*nodes.keys()][[*nodes.values()].index(h)]
            except:  # noqa
                log(f"{h} -> {job}", h=False)
                nodes[counter] = h
                counter += 1

        output = []
        for i in range(auto.getNoOfOutgoingDataArcs(_se, _index)):
            output.append(auto.getOutgoingData(_se, _index, i))

        for h in output:
            try:
                [*nodes.keys()][[*nodes.values()].index(h)]
            except:  # noqa
                log(f"{job} -> {h}", h=False)
                nodes[counter] = h
                counter += 1

        log(output)

    log("var nodes = new vis.DataSet([")
    for key, value in nodes.items():
        log("    {")
        log(f"       id: {key},")
        if not isinstance(value, int):
            val = value.split("_")[0]
            val1 = value.split("_")[1]
            log(f'       label: "{roc.getTokenIndex(val)}_{val1}",')
        else:
            log(f'       label: "{value}",')

        if isinstance(value, int):
            val = str(roc.getDataHash(value - 1)).replace("0x", "").lstrip("0")
            log(f'       title: "{val}",')
        else:
            log(f'       title: "{value}",')

        if "_" in str(value):
            log('       color: "#7BE141",')

        log("    },")

    log("]);")
    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    log("var edges = new vis.DataSet([")
    for job in jobs:
        output = job.split("_")
        _se = output[0]
        _index = output[1]
        nodes[counter] = _se
        counter += 1
        output = []
        for i in range(auto.getNoOfIncomingDataArcs(_se, _index)):
            output.append(auto.getIncomingData(_se, _index, i))

        for h in output:
            # log(f"{_h} -> {job}", h=False)
            _from = [*nodes.keys()][[*nodes.values()].index(h)]
            _to = [*nodes.keys()][[*nodes.values()].index(job)]

            log("    { ", end="")
            log(f'from: {_from}, to: {_to}, arrows: "to", color: ', end="")
            log('{ color: "red" } },')
            nodes[counter] = h
            counter += 1

        output = []
        for i in range(auto.getNoOfOutgoingDataArcs(_se, _index)):
            output.append(auto.getOutgoingData(_se, _index, i))

        for h in output:
            # log(f"{job} -> {_h}", h=False)
            _from = [*nodes.keys()][[*nodes.values()].index(job)]
            _to = [*nodes.keys()][[*nodes.values()].index(h)]
            log("    { ", end="")
            log(f'from: {_from}, to: {_to}, arrows: "to", color: ', end="")
            log('{ color: "blue" } },')
            nodes[counter] = h
            counter += 1

    log("]);")

    input_hash_1 = []
    output_hash_1 = []
    se_2 = md5_hash()
    tx = auto.addSoftwareExecRecord(
        se_2, 0, input_hash_1, output_hash_1, {"from": accounts[0]}
    )
    append_gas_cost("addSoftwareExecRecord", tx)

    # log(output)


def report():
    """Cleanup a testing directory once we are finished.

    __ https://stackoverflow.com/a/51025279/2402577"""
    print_gas_costs()  #


atexit.register(report)
