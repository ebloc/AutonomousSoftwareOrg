#!/usr/bin/env python3

import argparse
from merge import merge
import pathlib

# https://docs.python.org/3/howto/argparse.html
parser = argparse.ArgumentParser()
parser.add_argument("--verbosity", help="increase output verbosity")
parser.add_argument(
    "--merge",
    metavar="[original.gv]",
    type=pathlib.Path,
    nargs=1,
    help="merged executions of the same software",
)
args = parser.parse_args()
if args.verbosity:
    print("verbosity turned on")
elif args.merge:
    merge(args.merge)
