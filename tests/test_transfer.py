#!/usr/bin/python3
import brownie
import pytest

auto = None


@pytest.fixture(scope="module", autouse=True)
def my_own_session_run_at_beginning(_Auto):
    global auto  # type: ignore
    auto = _Auto


def test_AutonomousSoftwareOrg(accounts, token):
    print(auto.getAutonomousSoftwareOrgInfo())
    breakpoint()  # DEBUG
