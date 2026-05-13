#!/bin/bash
# generate_instance.sh — Generate a random MKP instance
#
# Usage:
#   ./generate_instance.sh [d] [m] > instance.txt
#
# Examples:
#   ./generate_instance.sh 5 20 > large_test.txt
#   ./generate_instance.sh 3 100 > many_knapsacks.txt

D=${1:-5}   # number of item types
M=${2:-10}  # number of knapsacks

echo "$D $M"
for i in $(seq 1 $D); do
    W=$((RANDOM % 10 + 1))        # weight 1-10
    P=$((RANDOM % 20 + 1))        # profit 1-20
    N=$((RANDOM % 50 + 1))        # multiplicity 1-50
    echo "$W $P $N"
done
CAPS=""
for j in $(seq 1 $M); do
    CAPS="$CAPS$((RANDOM % 100 + 10)) "  # capacity 10-109
done
echo "$CAPS"
