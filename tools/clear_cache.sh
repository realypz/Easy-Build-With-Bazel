#!/bin/bash

# Navigate to the src directory relative to the script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../src"
cd "$SRC_DIR" || exit

# Find all directories containing a MODULE.bazel file and run `bazelisk clean`
find . -name "MODULE.bazel" -execdir bazelisk clean --expunge \;

# Remove all MODULE.bazel.lock files
find . -name "MODULE.bazel.lock" -exec rm -f {} \;

echo "Bazel clean completed for all directories with MODULE.bazel."
