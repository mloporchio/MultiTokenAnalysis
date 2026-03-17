# Analysis of ERC-1155 token transfers

This repository contains code for reproducing the results described in the following papers:

[1] M. Loporchio, D. Di Francesco Maesa, A. Bernasconi, and L. Ricci, "Analyzing ERC-1155 Adoption: A Study of the Multi-token Ecosystem", Studies in Computational Intelligence. Springer Nature Switzerland, pp. 385–397, 2025. DOI: https://doi.org/10.1007/978-3-031-82427-2_32.

[2] M. Loporchio, D. Di Francesco Maesa, A. Bernasconi, and L. Ricci, "ERC-1155 under the lens: a graph-based analysis of the Ethereum multi-token standard", Appl Netw Sci, vol. 11, no. 1, Jan. 2026, DOI: https://doi.org/10.1007/s41109-025-00767-y. 

## Data availability

For space reasons, all data regarding ERC-1155 token transfers are available in the following Zenodo repository.

https://doi.org/10.5281/zenodo.14901527


## Technologies used

- Bash scripting
- C++
    - igraph (https://igraph.org/)
- Java
    - WebGraph (https://webgraph.di.unimi.it/)
- Python
    - Matplotlib (https://matplotlib.org/)
    - Numpy (https://numpy.org/)
    - Polars (https://pola.rs/)
    - Scipy (https://scipy.org/)

## Graph models

Graphs are imported and managed using the igraph and WebGraph libraries.
For the analysis, we adopt a **Weighted Token Transfer Graph (WTTG)**, namely a weighted directed graph where:
- each node represents an Ethereum address;
- each edge (u, v) represents all transfers from address u to address v.
- each edge is labeled with:
    - the total number of transfers;
    - the number of unique tokens transferred.