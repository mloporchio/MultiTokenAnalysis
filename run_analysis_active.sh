#!/bin/bash
#
#   This script runs the computation of the number of active contracts, tokens, 
#   and star networks over time. Note that the computation of active star networks
#   depends on the output of the `run_centralization.sh` script.
#
#   Author: Matteo Loporchio
#

CONTRACT_SCRIPT="active_contracts.py"
TOKEN_SCRIPT="active_stars.py"
STAR_SCRIPT="active_stars.py"

echo "Computing active ERC-1155 contracts..."
python3 ${CONTRACT_SCRIPT}
echo "Done!"

echo "Computing active ERC-1155 tokens..."
python3 ${TOKEN_SCRIPT}
echo "Done!"

echo "Computing active ERC-1155 star networks..."
python3 ${STAR_SCRIPT}
echo "Done!"


