#
#   This script reads the list of transfers associated with an ERC-1155 contract
#   and builds the edge list and node map of the corresponding Token Transfer Graph.
#
#   The input list is expected to be in newline-delimited JSON format.
#
#   INPUT:
#   -   path of the input newline-delimited JSON file;
#   -   path of the output node map file;
#   -   path of the output edge list file.
#
#   OUTPUT:
#   -   A TSV file representing the node map of the graph. 
#       The output node map file has the following format:
#           <address>\t<node_id>
#       where <address> represents the Ethereum address of the node and 
#       <node_id> is the unique integer identifier of the node (starting from 0).
#   -   A TSV file representing the edge list of the graph.
#       The output edge list file has the following format:
#           <from_id>\t<to_id>\t<count>\t<unique_token_ids>
#       where <from_id> and <to_id> are the integer identifiers of the source and target nodes, respectively,
#       <count> is the number of transfers from address <from_id> to address <to_id> and <unique_token_ids> 
#       is the number of unique token IDs transferred from <from_id> to <to_id>.
#
#   PRINT:
#   The script prints to stdout the following values separated by a TAB character:
#   -   number of nodes in the graph;
#   -   number of edges in the graph;
#   -   time taken to build the graph (in nanoseconds).
#
#   Author: Matteo Loporchio
#

import json
import sys
import time

INPUT_FILE = sys.argv[1]
NM_FILE = sys.argv[2]
EL_FILE = sys.argv[3]

nodes = dict()
edges = []
next_id = 0

def get_or_create_id(address):
    global nodes, next_id
    if not (address in nodes):
        nodes[address] = next_id
        next_id += 1
    return nodes[address]

def are_equal(e_1, e_2):
    return (e_1[0], e_1[1]) == (e_2[0], e_2[1])

start = time.time_ns()

input_fh = open(INPUT_FILE, 'r')
for line in input_fh:
    line = line.strip()
    transfer = json.loads(line)
    from_address = transfer['from']
    to_address = transfer['to']
    from_id = get_or_create_id(from_address)
    to_id = get_or_create_id(to_address)
    token_id = transfer['token_ids']
    edges.append((from_id, to_id, token_id))
input_fh.close()

# Sort the list of edges and write it to a file.
edges.sort(key=lambda x: (x[0], x[1]))

# Write the list of edges to the output file.
edge_fh = open(EL_FILE, 'w')
num_unique_edges = 0
if len(edges) > 0:
    prev = edges[0]
    count = 1
    token_ids = set()
    token_ids.add(prev[2])
    for i in range(1, len(edges)):
        curr = edges[i]
        if are_equal(curr, prev):
            count += 1
            token_ids.add(curr[2])
        else:
            edge_fh.write(f"{prev[0]}\t{prev[1]}\t{count}\t{len(token_ids)}\n")
            num_unique_edges += 1
            prev = curr
            count = 1
            token_ids.clear()
            token_ids.add(curr[2])
    edge_fh.write(f"{prev[0]}\t{prev[1]}\t{count}\t{len(token_ids)}\n")
    num_unique_edges += 1
edge_fh.close()

node_fh = open(NM_FILE, 'w')
for k in nodes.keys():
    node_fh.write(f"{k}\t{nodes[k]}\n")
node_fh.close()

end = time.time_ns()

print(f"{len(nodes)}\t{num_unique_edges}\t{end-start}")