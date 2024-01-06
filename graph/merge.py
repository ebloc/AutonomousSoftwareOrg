#!/usr/bin/env python3

from broker._utils._log import log
import networkx as nx


def merge(G):
    pass


def main():
    fn = "original.gv"
    G = nx.drawing.nx_pydot.read_dot(fn)
    #
    G = merge(G)


if __name__ == "__main__":
    main()
