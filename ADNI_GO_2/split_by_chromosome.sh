#!/bin/bash

PLINK="$1"
BFILE="$2"
TARGET="$3"

for chr in $(seq 1 22); do
     "$PLINK" --bfile "$BFILE" \
           --chr $chr \
           --recode \
           --out "$TARGET$chr" ;
done 
