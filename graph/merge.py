#!/usr/bin/env python3

# from broker._utils._log import log
import networkx as nx


def merge(G, n1, n2):
    """Merge two nodes.

    __ https://stackoverflow.com/a/58508427/2402577
    """
    # Get all predecessors and successors of two nodes
    predecessors = set(G.predecessors(n1)) | set(G.predecessors(n2))
    successors = set(G.successors(n1)) | set(G.successors(n2))
    #: new node with combined name
    name = str(n1) + "/" + str(n2)
    # Add predecessors and successors edges
    # We have DiGraph so there should be one edge per nodes pair
    G.add_edges_from([(p, name) for p in predecessors])
    G.add_edges_from([(name, s) for s in successors])
    #: remove old nodes
    G.remove_nodes_from([n1, n2])

    mapping = {name: str(n1)}
    G = nx.relabel_nodes(G, mapping)
    return G


def main():
    fn = "original.gv"
    G = nx.drawing.nx_pydot.read_dot(fn)

    sw_nodes = []
    for node in list(G.nodes):
        if "." in node:
            sw_nodes.append(node)

    group_sw = {}
    for node in sw_nodes:
        n = node.split(".")
        try:
            group_sw[n[0]].append(node)
        except:  # noqa
            group_sw[n[0]] = [node]

    for key, value in group_sw.items():
        if len(value) > 1:
            for idx, v in enumerate(value):
                if idx < len(value) - 1:
                    if idx == 0:
                        # print(f"merged: {v} {value[1]}")
                        G = merge(G, v, value[1])
                    else:
                        # print(f"merged: {value[0]} {value[idx + 1]}")
                        G = merge(G, value[0], value[idx + 1])
            #
            # print(value)

    for node in list(G.nodes):
        if "." in node:
            mapping = {node: f"{node.split('.')[0]}."}
            G = nx.relabel_nodes(G, mapping)

    nx.nx_pydot.write_dot(G, "merged.gv")


if __name__ == "__main__":
    main()
