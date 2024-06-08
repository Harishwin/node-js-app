#!/bin/bash

# Define the directory path
directory=".github/workflows"

# Check if the directory exists
if [ ! -d "$directory" ]; then
    # If it doesn't exist, create it
    mkdir -p "$directory"
    echo "Directory '$directory' created successfully."
else
    # If it exists, print a message
    echo "Directory '$directory' already exists."
fi

