#!/usr/bin/env python3

from broker._utils._log import log
import networkx as nx


def remove_edge_causing_most_cycles(G, cycles):
    """Removes single edge that causing most cycles."""
    edge_hit_rate = {}
    for cycle in cycles:
        for idx, node in enumerate(cycle):
            #: software node since it contains `.`
            if "." in cycle[idx]:
                try:
                    key = f"{cycle[idx]},{cycle[idx+1]}"
                except:  # noqa
                    key = f"{cycle[idx]},{cycle[0]}"

                try:
                    edge_hit_rate[key] += 1
                except:  # noqa
                    edge_hit_rate[key] = 1

        log(cycle)

    log(edge_hit_rate)
    _key = None
    _max = 0
    for key, value in edge_hit_rate.items():
        if value > _max:
            _max = value
            _key = key

    if _max > 1:
        to_remove = _key
        _from = to_remove.split(",")[0]
        _to = to_remove.split(",")[1]
    elif _max == 1:
        out = {}
        for key, value in edge_hit_rate.items():
            node = key.split(",")[0]
            out[node] = len(G.out_edges(node))

        #: reverse sort a dictionary by value
        out = {
            k: v for k, v in sorted(out.items(), key=lambda item: item[1], reverse=True)
        }
        _from = next(iter(out))
        _to = None
        for idx, node in enumerate(cycle):
            if node == _from:
                try:
                    _to = cycle[idx + 1]
                except:  # noqa
                    _to = cycle[0]

    log(f"removed {_from} -> {_to}")
    G.remove_edge(_from, _to)
    return G


def dagify(G):
    while True:
        cycles = list(nx.simple_cycles(G))
        if len(cycles) > 0:
            G = remove_edge_causing_most_cycles(G, cycles)
        else:
            break

    return G


def main():
    fn = "original.gv"
    G = nx.drawing.nx_pydot.read_dot(fn)
    G = dagify(G)


if __name__ == "__main__":
    main()
