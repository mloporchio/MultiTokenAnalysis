# Analysis of ERC-1155 transfers

This repository contains code for reproducing the results described in the following papers:

1) M. Loporchio, D. Di Francesco Maesa, A. Bernasconi, and L. Ricci, “Analyzing ERC-1155 Adoption: A Study of the Multi-token Ecosystem,” Studies in Computational Intelligence. Springer Nature Switzerland, pp. 385–397, 2025. doi: 10.1007/978-3-031-82427-2_32.

2) ...

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

1) **Token Transfer Graph**, i.e., a weighted directed graph where:
    - each node represents an Ethereum address;
    - each edge (u, v) represents all transfers from address u to address v.
    - each edge is labeled with:
        - the total number of transfers;
        - the number of unique tokens transferred;