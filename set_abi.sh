#!/bin/bash

. ~/venv/bin/activate
input="$(cat <<EOF
import json
file = open("abi.json","w")
json.dump(AutonomousSoftwareOrg.abi, file)
file.close()
EOF
)"
echo "$input"
echo "$input" | brownie console --network development
mv abi.json $HOME/ebloc-broker/broker/eblocbroker_scripts/abi_AutonomousSoftwareOrg.json
