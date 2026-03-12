#!/bin/bash
#
# This script runs plfit on the degree distributions of contracts.
# Author: Matteo Loporchio
#

INPUT_FILE="results/graph_creation.tsv"
OUTPUT_FILE="results/graph_degree_fit_new.tsv"
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