#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a folder name as an argument"
    exit 1
fi

# Base directory path
BASE_DIR="/Users/scottfeichter/Dropbox/____DEV 2025/Z__Resumes"

# Get today's date in MM.DD.YY format
TODAY=$(date +%m.%d.%y)

# Create new directory
mkdir -p "${BASE_DIR}/$1"

# Copy files from source directory
cp "${BASE_DIR}/_GENERAL/2025 Use These As Base/"* "${BASE_DIR}/$1/"

# Change to the new directory
cd "${BASE_DIR}/$1" || exit

# Rename the files
for file in *.pdf; do
    if [[ $file == *"Cover Letter"* ]]; then
        mv "$file" "SJF-CL-${1}-${TODAY}.pdf"
    elif [[ $file == *"References"* ]]; then
        mv "$file" "SJF-REF-${1}-${TODAY}.pdf"
    elif [[ $file == *"Jazzed"* ]]; then
        mv "$file" "SJF-RES-${1}-${TODAY}.pdf"
    fi
done

echo "Files have been copied and renamed successfully in folder: $1"
