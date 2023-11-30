#!/usr/bin/python3

from broker._utils._log import log
import brownie
import pytest
import random
from broker.eblocbroker_scripts.utils import Cent

auto = None
ebb = None


@pytest.fixture(scope="module", autouse=True)
def my_own_session_run_at_beginning(_Auto, _Ebb):
    global auto  # type: ignore
    global ebb  # type: ignore
    auto = _Auto
    ebb = _Ebb


def md5_hash():
    _hash = random.getrandbits(128)
    return "%032x" % _hash


def test_AutonomousSoftwareOrg(accounts, token):
    print(auto.getAutonomousSoftwareOrgInfo())

    _hash = md5_hash()
    auto.addSoftwareVersionRecord("alper.com", "1.0.0", _hash, {"from": accounts[0]})

    output = auto.getSoftwareVersionRecords(0)
    log(output[1])

    se = md5_hash()
    input_hash = [md5_hash(), "0xabcd"]
    output_hash = [md5_hash(), "0xabcde"]
    auto.addSoftwareExecRecord(se, 0, input_hash, output_hash, {"from": accounts[0]})
    input_hash = [md5_hash(), md5_hash(), md5_hash()]
    output_hash = [md5_hash(), md5_hash(), md5_hash()]
    auto.addSoftwareExecRecord(se, 0, input_hash, output_hash, {"from": accounts[0]})
    with brownie.reverts():
        output = auto.getSoftwareExecRecord(0)
        log(output)
        output = auto.getSoftwareExecRecord(1)
        log(output)

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
    #
    input_hash = [md5_hash(), "0xabcd"]
    output_hash = [md5_hash(), "0xabcde"]
    index = 0
    auto.addSoftwareExecRecord(
        se, index, input_hash, output_hash, {"from": accounts[0]}
    )
    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    log()
    job_name = f"{se}_{index}"
    jobs = [job_name]

    counter = 1
    nodes = {}
    for job in jobs:
        output = job.split("_")
        _se = output[0]
        _index = output[1]
        nodes[counter] = job
        counter += 1
        output = auto.getIncomings(_se, _index)
        for h in output:
            _h = str(h)[2:].lstrip("0")
            # _h = f"0x{_h}"
            log(f"{_h} -> {job}", h=False)
            nodes[counter] = _h
            counter += 1

        output = auto.getOutgoings(_se, _index)
        for h in output:
            _h = str(h)[2:].lstrip("0")
            # _h = f"0x{_h}"
            log(f"{job} -> {_h}", h=False)
            nodes[counter] = _h
            counter += 1

        log(output)

    # output = auto.getSoftwareExecRecord(0)
    # log(output)

    log("var nodes = new vis.DataSet([")
    for key, value in nodes.items():
        log("    {")
        log(f"       id: {key},")
        log(f'       label: "{value}",')
        log(f'       title: "I have popup"')
        if "_" in value:
            log('       color: "#7BE141",')

        log("    },")

    log("]);")
    log("var edges = new vis.DataSet([")
    for job in jobs:
        output = job.split("_")
        _se = output[0]
        _index = output[1]
        nodes[counter] = _se
        counter += 1
        output = auto.getIncomings(_se, _index)
        for h in output:
            _h = str(h)[2:].lstrip("0")
            # _h = f"0x{_h}"
            # log(f"{_h} -> {job}", h=False)
            _from = [*nodes.keys()][[*nodes.values()].index(_h)]
            _to = [*nodes.keys()][[*nodes.values()].index(job)]

            log("    { ", end="")
            log(f'from: {_from}, to: {_to}, arrows: "to", color: ', end="")
            log('{ color: "red" } },')
            nodes[counter] = _h
            counter += 1

        output = auto.getOutgoings(_se, _index)
        for h in output:
            _h = str(h)[2:].lstrip("0")
            # _h = f"0x{_h}"
            # log(f"{job} -> {_h}", h=False)
            _from = [*nodes.keys()][[*nodes.values()].index(job)]
            _to = [*nodes.keys()][[*nodes.values()].index(_h)]
            log("    { ", end="")
            log(f'from: {_from}, to: {_to}, arrows: "to", color: ', end="")
            log('{ color: "blue" } },')
            nodes[counter] = _h
            counter += 1

        log("]);")

        # log(output)

    breakpoint()  # DEBUG


"""
digraph G {

}
"""
