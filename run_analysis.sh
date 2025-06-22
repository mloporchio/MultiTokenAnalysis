#!/bin/bash
#
# This script runs the experiments for the paper.
#
# Author: Matteo Loporchio
#

NUM_CONTRACTS=100
OUTPUT_DIR="results"
OUTPUT_FILE="${OUTPUT_DIR}/graph_stats.tsv"
DEGREE_DIR="${OUTPUT_DIR}/degree"
CONNECTIVITY_DIR="${OUTPUT_DIR}/connectivity"
WEBGRAPH_DISTANCE_CLASS="WebGraphDistance"
WEBGRAPH_DIAMETER_CLASS="WebGraphDiameter"
CLASSPATH="bin:lib/*"

mkdir -p $DEGREE_DIR $CONNECTIVITY_DIR

printf "contract_id\tnum_nodes\tnum_edges\tcoverage_wcc\tcoverage_scc\tclustering\tdensity\treciprocity\tdistance\tdiameter\n" > $OUTPUT_FILE
for (( i=0 ; i < NUM_CONTRACTS ; i++)) do
    echo "Processing contract $i..."
    INPUT_FILE="results/graphs/el_${i}.tsv"
    WEBGRAPH_PREFIX="results/webgraphs/webgraph_${i}"
    DEGREE_FILE="${DEGREE_DIR}/degree_${i}.tsv"
    CONNECTIVITY_FILE="${CONNECTIVITY_DIR}/connectivity_${i}.tsv"
    DEGREE_OUT=$(./graph_degree $INPUT_FILE $DEGREE_FILE)
    CONNECTIVITY_OUT=$(./graph_connectivity $INPUT_FILE $CONNECTIVITY_FILE)
    NUM_NODES=$(echo $DEGREE_OUT | cut -d' ' -f1)
    NUM_EDGES=$(echo $DEGREE_OUT | cut -d' ' -f2)
    COVERAGE_OUT=$(python3 graph_coverage.py $CONNECTIVITY_FILE)
    COVERAGE_WCC=$(echo $COVERAGE_OUT | cut -d' ' -f1)
    COVERAGE_SCC=$(echo $COVERAGE_OUT | cut -d' ' -f2)
    CLUSTERING=$(./graph_clustering ${INPUT_FILE} | cut -d$'\t' -f3)
    DENSITY=$(./graph_density ${INPUT_FILE} | cut -d$'\t' -f3)
    RECIPROCITY=$(./graph_reciprocity ${INPUT_FILE} | cut -d$'\t' -f3)
    DISTANCE=$(java -Xmx128g -cp ${CLASSPATH} ${WEBGRAPH_DISTANCE_CLASS} ${WEBGRAPH_PREFIX} 2>/dev/null | cut -d$'\t' -f3)
    DIAMETER=$(java -Xmx128g -cp ${CLASSPATH} ${WEBGRAPH_DIAMETER_CLASS} ${WEBGRAPH_PREFIX} 2>/dev/null | cut -d$'\t' -f3)
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" $i $NUM_NODES $NUM_EDGES $COVERAGE_WCC $COVERAGE_SCC $CLUSTERING $DENSITY $RECIPROCITY $DISTANCE $DIAMETER >> $OUTPUT_FILE
    echo "Done!"
done