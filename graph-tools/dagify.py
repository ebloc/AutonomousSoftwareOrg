#!/usr/bin/env python3

from broker._utils._log import log
import networkx as nx


def _dagify(G):
    sw_nodes = []
    data_nodes = []
    for node in list(G.nodes):
        if "." in node:
            sw_nodes.append(node)
        else:
            data_nodes.append(node)

    _dict = {}
    for sw_node in sw_nodes:
        output = sw_node.split(".")
        _dict[sw_node] = int(output[1])

    order_dict = {}
    hit_node = {}
    pr = {k: v for k, v in sorted(_dict.items(), key=lambda item: item[1])}
    for node in pr:
        out_nodes = G.out_edges(node)
        for out_node in out_nodes:
            if out_node[1] not in hit_node:
                hit_node[out_node[1]] = True
                try:
                    order_dict[out_node[0]].append(out_node[1])
                except:
                    order_dict[out_node[0]] = []
                    order_dict[out_node[0]].append(out_node[1])

    log("List of software in execution order and their initial generated data files:")
    log(order_dict)
    # print(f"data={data_nodes}\n")
    # print(f"sw={sw_nodes}")


def dagify(fn="original.gv"):
    G = nx.drawing.nx_pydot.read_dot(fn)
    G = _dagify(G)


if __name__ == "__main__":
    dagify()
