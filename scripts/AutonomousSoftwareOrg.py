#!/usr/bin/python3

import json

from brownie import accounts, network, AutonomousSoftwareOrg


def main():
    acct = accounts.load("alper.json", password="alper")
    auto = AutonomousSoftwareOrg.deploy(
        "0x01234",
        2,
        3,
        "0x",
        "0x00A7413ACb69D7F9a03ab92B77c49628bD340274",  # eBlocBroker
        "0x17e85EF468e5e085659d0443e29856a9054f0E7A",  # ResearchCertificate
        {"from": acct},
    )
    if network.show_active() == "private":
        from os.path import expanduser

        home = expanduser("~")
        BASE = f"{home}/ebloc-broker/broker/eblocbroker_scripts"
        abi_file = f"{BASE}/abi_AutonomousSoftwareOrg.json"
        contract_file = f"{BASE}/contract_AutonomousSoftwareOrg.json"
        json.dump(auto.abi, open(abi_file, "w"))
        info = {"txHash": auto.tx.txid, "address": auto.address}
        with open(contract_file, "w") as fp:
            json.dump(info, fp)
    elif network.show_active() == "development":
        print("development")
