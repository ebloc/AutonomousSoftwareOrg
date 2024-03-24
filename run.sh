#!/bin/bash

TEST_ALL=1
source ~/venv/bin/activate
echo -n "brownie compile "
brownie compile >/dev/null 2>&1
echo "done"
$HOME/ebloc-broker/broker/_daemons/ganache.py 8547
if [ $TEST_ALL -eq 1 ]; then
    pytest tests -s -x --disable-pytest-warnings --log-level=INFO -v --tb=line # tests all cases
else  #: gives priority
    pytest tests --capture=sys -s -x -k "test_paper" --disable-pytest-warnings -vv --tb=line
fi
rm -rf reports/
