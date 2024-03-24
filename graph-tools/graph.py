#!/usr/bin/env python3

from broker._utils._log import log
from broker._utils.tools import print_tb
from broker.errors import QuietExit
import networkx as nx


def page_rank(fn):
    if type(fn) is list:
        fn = fn[0]

    G = nx.drawing.nx_pydot.read_dot(fn)
    index_k = 0
    _max = 0.0
    pr = nx.pagerank(G, alpha=0.9)
    #: sort by values
    pr = {k: v for k, v in sorted(pr.items(), key=lambda item: item[1])}
    log("#> PageRank results of each software execution:")
    for key, value in pr.items():
        if "." in key:
            print(f"{key} => {value}")

        if value > _max:
            index_k = key
            _max = value

    # print(f"* pr {index_k} => {_max}")
    return index_k


def _knocked_down(G, knocked_rate, node, is_verbose=False):
    queue = [node]
    knocked = [node]
    while True:
        if queue:
            init_node = queue[0]
            for edge in G.out_edges(init_node):
                out_node = edge[1]
                if out_node not in knocked:
                    queue.append(out_node)
                    knocked.append(out_node)

            queue.remove(init_node)
        else:
            knocked_rate[node] = len(knocked)
            break

    if is_verbose:
        log(f"* knocked_node_size={len(knocked)} for node={node}")
        for knocked_node in knocked:
            G.remove_node(knocked_node)

        log("** remained_nodes=", end="")
        log(list(G.nodes))


def knocked_down(fn, start_node):
    G = nx.drawing.nx_pydot.read_dot(fn)
    knocked_rate = {}
    _knocked_down(G, knocked_rate, start_node, is_verbose=True)


def _most_knocked_down(G, data_nodes):
    knocked_rate = {}
    for start_node in data_nodes:
        _knocked_down(G, knocked_rate, start_node)

    _key = 0
    _max = 0
    for key, value in knocked_rate.items():
        if value > _max:
            _max = value
            _key = key

    # log(knocked_rate)
    # nx.nx_pydot.write_dot(G, "knocked.gv")
    return _key, _max


def most_knocked_down(fn):
    if type(fn) is list:
        fn = fn[0]

    G = nx.drawing.nx_pydot.read_dot(fn)
    #
    sw_nodes = []
    data_nodes = []
    for node in list(G.nodes):
        if "." in node:
            sw_nodes.append(node)
        else:
            data_nodes.append(node)

    node, knocked = _most_knocked_down(G, data_nodes)
    return node, knocked


def _jump_one_step_behind(G, init_node):
    track = {}
    for edge in G.in_edges(init_node):
        _sum = 0
        for _edge in G.in_edges(edge[0]):
            _sum += float(G.nodes[_edge[0]]["weight"])

        track[_edge[1]] = _sum

    pr = {k: v for k, v in sorted(track.items(), key=lambda item: item[1])}
    return pr
    breakpoint()  # DEBUG


def jump_one_step_behind(fn, init_node):
    G = nx.drawing.nx_pydot.read_dot(fn)
    return _jump_one_step_behind(G, init_node)


def main():
    fn = "original.gv"
    G = nx.drawing.nx_pydot.read_dot(fn)

    _jump_one_step_behind(G, "42")
    #
    sw_nodes = []
    data_nodes = []
    for node in list(G.nodes):
        if "." in node:
            sw_nodes.append(node)
        else:
            data_nodes.append(node)

    print(f"data={data_nodes}\n")
    print(f"sw={sw_nodes}")

    page_rank(fn)
    node, knocked = _most_knocked_down(G, data_nodes)
    log(f"* node={node} most_knocked_len={knocked}")
    #
    knocked_rate = {}
    start_node = "11"
    _knocked_down(G, knocked_rate, start_node, is_verbose=True)
    breakpoint()  # DEBUG


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
    except QuietExit as e:
        print(f"#> {e}")
    except Exception as e:
        print_tb(str(e))
