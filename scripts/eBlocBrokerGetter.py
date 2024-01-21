#!/usr/bin/python3

import json

from brownie import accounts, network, eBlocBrokerGetter


def main():
    acct = accounts.load("alper.json", password="alper")
    auto = eBlocBrokerGetter.deploy(
        "0xAf3095FA409a4043d679a65D287658346bf38E7A",  # eBlocBroker
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
