#!/bin/bash

# Create a log directory if it doesn't exist
mkdir -p logs

# Run all .R files sequentially
for file in add_*_data*.R; do
    echo "Starting $file..."
    Rscript "$file" > "logs/${file%.R}.log" 2>&1
    if [ $? -eq 0 ]; then
        echo "$file completed successfully. Log: logs/${file%.R}.log"
    else
        echo "Error running $file. Check logs/${file%.R}.log for details."
        exit 1 # Exit on the first error, or remove this line to continue.
    fi
done

echo "All R scripts processed."
