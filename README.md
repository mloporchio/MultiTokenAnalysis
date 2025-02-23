# Analysis of ERC-1155 transfers

This repository contains code for reproducing the results described in the following paper:

"Analyzing ERC-1155 Adoption: a Study of the Multi-Token Ecosystem" by Matteo Loporchio, Damiano Di Francesco Maesa, Anna Bernasconi, and Laura Ricci.

## Data availability

For space reasons, all data regarding ERC-1155 token transfers are available in the following Zenodo repository.

http://...

## Technologies used

- C/C++
- Java
- Python
- Bash
- ...

## Graph models

Graphs are imported and managed using the igraph and WebGraph libraries.
The currently supported graph models are:

1) Weighted directed graph:
    - each node represents an Ethereum address;
    - each edge (u, v) represents all transfers from address u to address v.
    - each edge is labelled with:
        - the total number of transfers;
        - the number of unique tokens transferred;
        - the total amount of tokens transferred.

2) Unweighted undirected graph:
    - A node represents an Ethereum address;
    - There is an edge (u, v) if there exists a transfer between u and v (either u -> v or v -> u).