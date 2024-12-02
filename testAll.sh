#!/bin/bash

# Define the executable names
c_version="./mywc"
flat_version="./mywc_flat"

# Directory containing the test files
test_dir="."

# Loop through each test file in the directory that matches "mywc_*.txt"
for test_file in $test_dir/mywc_*.txt; do
    echo "Running test on $test_file"

    # Run the C version
    $c_version < $test_file > c_output.txt

    # Run the flattened version
    $flat_version < $test_file > flat_output.txt

    # Compare the outputs of the C and the flattened version
    if cmp -s c_output.txt flat_output.txt; then
        echo "Test on $test_file PASSED."
    else
        echo "Test on $test_file FAILED."
        echo "Differences:"
        diff c_output.txt flat_output.txt
    fi
done

# Clean up temporary files
rm c_output.txt flat_output.txt
