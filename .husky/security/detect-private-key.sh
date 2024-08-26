#!/bin/bash

# Define patterns for Ethereum and Solana private keys
ETH_PATTERN='(0x)?[A-Fa-f0-9]{64}'
SOL_PATTERN='^[1-9A-HJ-NP-Za-km-z]{88}$'

# Debug flag: Set to true to enable debug messages
DEBUG=false

# Function to output debug messages
debug() {
  if [ "$DEBUG" = true ]; then
    echo "Debug: $1"
  fi
}

# 1. Debug message: Start of the script
debug "Starting the private key detection script."

# Load exceptions from the external file
EXCEPTIONS_FILE="$(dirname "$0")/security/private-key-exceptions.sh"
if [ -f "$EXCEPTIONS_FILE" ]; then
  debug "Loading exceptions from $EXCEPTIONS_FILE."
  source "$EXCEPTIONS_FILE"
else
  echo "Warning: private-key-exceptions.sh file not found."
  exit 1
fi

# Function to check if a line matches any exception
is_exception() {
  local line="$1"
  debug "Checking if line matches any exception."
  for exception in "${EXCEPTIONS[@]}"; do
    debug "Comparing with exception: $exception"
    if [[ "$line" == *"$exception"* ]]; then
      debug "Line matches exception."
      return 0
    fi
  done
  debug "No match found for the line."
  return 1
}

# Check for private keys in staged files
FILES=$(git diff --cached --name-only --diff-filter=ACM)
debug "Files to check: $FILES"

if [ -z "$FILES" ]; then
  debug "No matching files found."
  exit 0
fi

for FILE in $FILES; do
  debug "Checking file: $FILE"
  if grep -Eq "$ETH_PATTERN" "$FILE" || grep -Eq "$SOL_PATTERN" "$FILE"; then
    debug "Found potential private key pattern in $FILE."
    MATCHES=$(grep -En "$ETH_PATTERN|$SOL_PATTERN" "$FILE")
    while IFS= read -r MATCH; do
      LINE_NUMBER=$(echo "$MATCH" | cut -d: -f1)
      LINE_CONTENT=$(echo "$MATCH" | cut -d: -f2-)
      debug "Checking line $LINE_NUMBER: $LINE_CONTENT"

      # Capture the return value of is_exception
      if is_exception "$LINE_CONTENT"; then
        RESULT=0
        debug "Line is an exception."
      else
        RESULT=1
        debug "Line is NOT an exception."
      fi

      # Check if the line is in the exception list
      if [[ $RESULT -eq 0 ]]; then
        echo "Skipped exception found in $FILE at line $LINE_NUMBER"
      else
        echo "Error: Detected a potential private key in $FILE at line $LINE_NUMBER"
        echo ">> $LINE_CONTENT"
        echo "If this is a false positive, please add the key to the '$EXCEPTIONS_FILE' file."
        echo "Commit aborted."
        exit 1
      fi
    done <<< "$MATCHES"
  else
    debug "No private key pattern found in $FILE."
  fi
done

debug "Finished checking all files."
