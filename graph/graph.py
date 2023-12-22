#!/usr/bin/env python3

#!/usr/bin/env python3

from broker._utils._log import log
import networkx as nx


def page_rank(G):
    index_k = 0
    _max = 0.0
    pr = nx.pagerank(G, alpha=0.9)
    for key, value in pr.items():
        # print(f"{key} => {value}")
        if value > _max:
            index_k = key
            _max = value

    print(f"* pr {index_k} => {_max}")
    return index_k


def _knocked(knocked_rate, queue, knocked, start_node):
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
            knocked_rate[start_node] = len(knocked)
            break


def knocked_down(G):
    knocked_rate = {}
    for start_node in data_nodes:
        queue = [start_node]
        knocked = [start_node]
        _knocked(knocked_rate, queue, knocked, start_node)

    log(knocked_rate)
    #
    knocked_rate = {}
    queue = ["11"]
    knocked = ["11"]
    _knocked(knocked_rate, queue, knocked, start_node)
    for knocked_node in knocked:
        G.remove_node(knocked_node)

    print(list(G.nodes))
    # nx.nx_pydot.write_dot(G, "knocked.gv")


fn = "original.gv"
G = nx.drawing.nx_pydot.read_dot(fn)

sw_nodes = []
data_nodes = []
for node in list(G.nodes):
    if "." in node:
        sw_nodes.append(node)
    else:
        data_nodes.append(node)

print(f"data={data_nodes}")
print()
print(f"sw={sw_nodes}")

page_rank(G)
knocked_down(G)
breakpoint()  # DEBUG
