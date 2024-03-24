#!/usr/bin/env python3

import argparse
from merge import merge
from graph import page_rank, most_knocked_down, knocked_down, jump_one_step_behind
from dagify import dagify
from broker._utils._log import log
import pathlib

# https://docs.python.org/3/howto/argparse.html
parser = argparse.ArgumentParser()
parser.add_argument("--verbosity", help="increase output verbosity")
parser.add_argument(
    "--dagify",
    metavar="[file.gv]",
    type=pathlib.Path,
    nargs=1,
    help="Dagify",
)

parser.add_argument(
    "--merge",
    metavar="[file.gv]",
    type=pathlib.Path,
    nargs=1,
    help="merged executions of the same software",
)
parser.add_argument(
    "--pagerank",
    metavar="[file.gv]",
    type=pathlib.Path,
    nargs=1,
    help="Calculate page pagerank on the given graph",
)
parser.add_argument(
    "--most_knocked_down",
    metavar="[file.gv]",
    type=pathlib.Path,
    nargs=1,
    help="Node that most nodes knocked down",
)
parser.add_argument(
    "--knocked_down",
    metavar="[file.gv] [n]",
    nargs=2,
    help="Nodes that are knocked down",
)
parser.add_argument(
    "--jump_one_step_behind",
    metavar="[file.gv] [n]",
    nargs=2,
    help="JumpOneStepBehind",
)

args = parser.parse_args()
if args.verbosity:
    print("verbosity turned on")
elif args.merge:
    merge(args.merge)
elif args.pagerank:
    page_rank(args.pagerank)
elif args.most_knocked_down:
    node, knocked = most_knocked_down(args.most_knocked_down)
    log(f"* node={node} ; most_knocked_len={knocked}")
elif args.knocked_down:
    knocked_down(args.knocked_down[0], args.knocked_down[1])
elif args.jump_one_step_behind:
    pr = jump_one_step_behind(
        args.jump_one_step_behind[0], args.jump_one_step_behind[1]
    )
    log("#> Nodes from smallest sum of input to greatest:")
    log(pr)
elif args.dagify:
    dagify(args.dagify[0])
