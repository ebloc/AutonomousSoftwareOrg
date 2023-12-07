#!/bin/bash

network="bloxberg_core"
echo -e "## network="$network
rm -rf build/
brownie compile
brownie run AutonomousSoftwareOrg --network $network
printf "## setting abi... "
./set_abi.sh  >/dev/null 2>&1
echo "done"
main | tee deploy_output.txt
