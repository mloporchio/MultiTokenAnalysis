#!/bin/bash
#
#   This script fits power law functions on the in-degree and out-degree distributions
#   of the ERC-1155 Token Transfer Graphs.
#
#   NOTICE: The script requires the `plfit` utility (https://github.com/ntamas/plfit) to be installed.
#   The PLFIT_EXEC variable should be set in advance to the path of the `plfit` executable.
#
#   The script produces a TSV file with the following fields:
#   - contract_id: numerical identifier of the contract;
#   - measure: type of degree distribution (in-degree or out-degree);
#   - alpha: fitted exponent of the power law distribution;
#   - x_min: minimum X value for which the power law distribution holds;
#   - L: log-likelihood of the fitted distribution;
#   - D: Kolmogorov-Smirnov statistic of the fitted distribution;
#   - p_value: p-value of the goodness-of-fit test.
#   
#   Author: Matteo Loporchio
#

INPUT_FILE="results/graph_creation.tsv"
OUTPUT_FILE="results/graph_degree_fit.tsv"
PLFIT_EXEC="~/plfit/build/src/plfit"
TEMP_DIR="tmp"
MEASURES=("in_deg" "out_deg")
CONTRACT_IDS=( $(cut -d$'\t' -f1 ${INPUT_FILE} | tail -n +2 | tr '\n' ' ') )

mkdir -p $TEMP_DIR

printf "contract_id\tmeasure\talpha\tx_min\tL\tD\tp_value\n" > $OUTPUT_FILE
for i in "${CONTRACT_IDS[@]}"; do
    echo "Processing contract $i..."
    DEGREE_FILE="results/degree/degree_${i}.tsv"
    for ((j=2; j<=3; j++)) do
        TEMP_FILE="${TEMP_DIR}/temp_${i}_${j}.tsv"
        (cat ${DEGREE_FILE} | cut -d$'\t' -f${j} | tail -n +2) > ${TEMP_FILE}
        MEASURE_NAME=${MEASURES[$((j-2))]}
        if PLFIT_OUT=$((eval ${PLFIT_EXEC} -p exact -b ${TEMP_FILE}) 2>/dev/null); then
            # Fitted exponent, minimum X value, log-likelihood (L), Kolmogorov-Smirnov statistic (D) and p-value (p)
            ALPHA=$(echo $PLFIT_OUT | cut -d' ' -f3)
            X_MIN=$(echo $PLFIT_OUT | cut -d' ' -f4)
            LL=$(echo $PLFIT_OUT | cut -d' ' -f5)
            KS=$(echo $PLFIT_OUT | cut -d' ' -f6)
            P_VALUE=$(echo $PLFIT_OUT | cut -d' ' -f7)
            printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$i" "$MEASURE_NAME" "$ALPHA" "$X_MIN" "$LL" "$KS" "$P_VALUE" >> $OUTPUT_FILE
        else
            echo "plfit: failure for contract $i and measure $MEASURE_NAME."
            printf "%s\t%s\tnull\tnull\tnull\tnull\tnull\n" "$i" "$MEASURE_NAME" >> $OUTPUT_FILE
        fi
        rm $TEMP_FILE
    done
    echo "Done!"
done

rm -rf $TEMP_DIR