#!/usr/bin/python3

import pytest


@pytest.fixture(scope="function", autouse=True)
def isolate(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="module")
def token(Token, accounts):
    return Token.deploy("Test Token", "TST", 18, 1e21, {"from": accounts[0]})


@pytest.fixture(scope="module")
def _Auto(AutonomousSoftwareOrg, accounts):
    # _cfg.TOKEN = tx = USDTmy.deploy({"from": accounts[0]})
    # print(tx.address)
    # accounts[0].deploy(Lib)
    yield AutonomousSoftwareOrg.deploy("0x01234", 2, 3, "0x", {"from": accounts[0]})
