#!/bin/bash

# Define patterns for Ethereum and Solana private keys
ETH_PATTERN='(0x)?[A-Fa-f0-9]{64}'
SOL_PATTERN='^[1-9A-HJ-NP-Za-km-z]{88}$'

# Load exceptions from the external file
if [ -f "$(dirname "$0")/security/private-key-exceptions.sh" ]; then
  source "$(dirname "$0")/security/private-key-exceptions.sh"
else
  echo "Warning: private-key-exceptions.sh file not found."
  exit 1
fi

# Function to check if a line matches any exception
is_exception() {
  local line="$1"
  for exception in "${EXCEPTIONS[@]}"; do
    if [[ "$line" == *"$exception"* ]]; then
      return 0
    fi
  done
  return 1
}

# Check for private keys in staged files
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts|sol|py|sh|txt|json)$')
if [ -z "$FILES" ]; then
  exit 0
fi

for FILE in $FILES; do
  if grep -Eq "$ETH_PATTERN" "$FILE" || grep -Eq "$SOL_PATTERN" "$FILE"; then
    MATCHES=$(grep -En "$ETH_PATTERN|$SOL_PATTERN" "$FILE")
    while IFS= read -r MATCH; do
      LINE_NUMBER=$(echo "$MATCH" | cut -d: -f1)
      LINE_CONTENT=$(echo "$MATCH" | cut -d: -f2-)

      # Capture the return value of is_exception
      if is_exception "$LINE_CONTENT"; then
        RESULT=0
      else
        RESULT=1
      fi

      # Check if the line is in the exception list
      if [[ $RESULT -eq 0 ]]; then
        echo "Skipped exception found in $FILE at line $LINE_NUMBER"
      else
        echo "Error: Detected a potential private key in $FILE at line $LINE_NUMBER"
        echo ">> $LINE_CONTENT"
        echo "If this is a false positive, please add the key to the '$(dirname "$0")/security/private-key-exceptions.sh' file."
        echo "Commit aborted."
        exit 1
      fi
    done <<< "$MATCHES"
  fi
done

exit 0
