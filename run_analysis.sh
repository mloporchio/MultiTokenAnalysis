#!/bin/bash
#
#   This script runs the main experiments regarding graphs.
#
#   The script processes each graph and computes the following measures:
#   - num_nodes: number of nodes in the graph;
#   - num_edges: number of edges in the graph;
#   - coverage_wcc: coverage of the largest weakly connected component;
#   - coverage_scc: coverage of the largest strongly connected component;
#   - clustering: global clustering coefficient (i.e., transitivity);
#   - density: graph density;
#   - reciprocity: graph reciprocity;
#   - distance: average shortest path length;
#   - diameter: graph diameter.
#
#   Results are written in a TSV file where each row describes the graph of a single contract.
#
#   Author: Matteo Loporchio
#

INPUT_FILE="results/graph_creation.tsv"
OUTPUT_DIR="results"
OUTPUT_FILE="${OUTPUT_DIR}/graph_stats.tsv"
DEGREE_DIR="${OUTPUT_DIR}/degree"
CONNECTIVITY_DIR="${OUTPUT_DIR}/connectivity"
WEBGRAPH_DISTANCE_CLASS="WebGraphDistance"
WEBGRAPH_DIAMETER_CLASS="WebGraphDiameter"
BIN_DIR="bin"
LIB_DIR="lib"
CLASSPATH="${BIN_DIR}:${LIB_DIR}/*"

mkdir -p $DEGREE_DIR $CONNECTIVITY_DIR

printf "contract_id\tnum_nodes\tnum_edges\tcoverage_wcc\tcoverage_scc\tclustering\tdensity\treciprocity\tdistance\tdiameter\n" > $OUTPUT_FILE
CONTRACT_IDS=( $(cut -d$'\t' -f1 ${INPUT_FILE} | tail -n +2 | tr '\n' ' ') )
for i in "${CONTRACT_IDS[@]}"; do
    echo "Processing contract $i..."
    INPUT_FILE="results/graphs/el_${i}.tsv"
    WEBGRAPH_PREFIX="results/webgraphs/webgraph_${i}"
    DEGREE_FILE="${DEGREE_DIR}/degree_${i}.tsv"
    CONNECTIVITY_FILE="${CONNECTIVITY_DIR}/connectivity_${i}.tsv"
    DEGREE_OUT=$(./${BIN_DIR}/graph_degree $INPUT_FILE $DEGREE_FILE)
    CONNECTIVITY_OUT=$(./${BIN_DIR}/graph_connectivity $INPUT_FILE $CONNECTIVITY_FILE)
    NUM_NODES=$(echo $DEGREE_OUT | cut -d' ' -f1)
    NUM_EDGES=$(echo $DEGREE_OUT | cut -d' ' -f2)
    COVERAGE_OUT=$(python3 graph_coverage.py $CONNECTIVITY_FILE)
    COVERAGE_WCC=$(echo $COVERAGE_OUT | cut -d' ' -f1)
    COVERAGE_SCC=$(echo $COVERAGE_OUT | cut -d' ' -f2)
    CLUSTERING=$(./${BIN_DIR}/graph_clustering ${INPUT_FILE} | cut -d$'\t' -f3)
    DENSITY=$(./${BIN_DIR}/graph_density ${INPUT_FILE} | cut -d$'\t' -f3)
    RECIPROCITY=$(./${BIN_DIR}/graph_reciprocity ${INPUT_FILE} | cut -d$'\t' -f3)
    DISTANCE=$(java -Xmx128g -cp ${CLASSPATH} ${WEBGRAPH_DISTANCE_CLASS} ${WEBGRAPH_PREFIX} 2>/dev/null | cut -d$'\t' -f3)
    DIAMETER=$(java -Xmx128g -cp ${CLASSPATH} ${WEBGRAPH_DIAMETER_CLASS} ${WEBGRAPH_PREFIX} 2>/dev/null | cut -d$'\t' -f3)
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" $i $NUM_NODES $NUM_EDGES $COVERAGE_WCC $COVERAGE_SCC $CLUSTERING $DENSITY $RECIPROCITY $DISTANCE $DIAMETER >> $OUTPUT_FILE
    echo "Done!"
done