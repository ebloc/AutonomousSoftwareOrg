#!/usr/bin/python3

from broker._utils._log import log
import brownie
import pytest
import random

auto = None


@pytest.fixture(scope="module", autouse=True)
def my_own_session_run_at_beginning(_Auto):
    global auto  # type: ignore
    auto = _Auto


def md5_hash():
    _hash = random.getrandbits(128)
    return "%032x" % _hash


def test_AutonomousSoftwareOrg(accounts, token):
    print(auto.getAutonomousSoftwareOrgInfo())
    _hash = md5_hash()
    auto.addSoftwareVersionRecord("alper.com", "1.0.0", _hash, {"from": accounts[0]})
    output = auto.getSoftwareVersionRecords(0)
    log(output[1])
    input_hash = [md5_hash(), "0xabcd"]
    output_hash = [md5_hash(), "0xabcde"]
    auto.addSoftwareExecRecord("1.0.0", "alper.com", input_hash, output_hash)

    input_hash = [md5_hash(), md5_hash(), md5_hash()]
    output_hash = [md5_hash(), md5_hash(), md5_hash()]
    auto.addSoftwareExecRecord("1.0.0", "alper.com", input_hash, output_hash)

    output = auto.getSoftwareExecRecord(0)
    log(output)
    output = auto.getSoftwareExecRecord(1)
    log(output)

    breakpoint()  # DEBUG
