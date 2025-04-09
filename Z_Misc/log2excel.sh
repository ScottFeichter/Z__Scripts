#!/bin/bash

# log2excel.sh
if [ "$#" -lt 1 ]; then
    echo "Usage: ./log2excel.sh <input_file> [output_file]"
    exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE=${2:-"${INPUT_FILE%.*}.xlsx"}

ts-node logToExcel.ts "$INPUT_FILE" "$OUTPUT_FILE"
