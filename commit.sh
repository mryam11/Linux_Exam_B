#!/bin/bash

# Path to the CSV file
CSV_FILE="bugs.csv"

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
  echo "Error: CSV file '$CSV_FILE' not found."
  exit 1
fi

# Read data from the CSV (ensure that IFS is set correctly to avoid trailing whitespace issues)
# Skip the first line (header row) using awk's NR variable
tail -n +2 "$CSV_FILE" | while IFS=',' read -r BugID Description Branch DevName Priority GitHubURL; do

    # Ensure that required fields are not empty
    if [ -z "$BugID" ] || [ -z "$Description" ] || [ -z "$Branch" ] || [ -z "$DevName" ] || [ -z "$Priority" ] || [ -z "$GitHubURL" ]; then
        echo "Error: Missing required field in CSV."
        exit 1
    fi
    
    # Trim whitespace from variables (sometimes there are extra spaces in CSV data)
    BugID=$(echo "$BugID" | xargs)
    Description=$(echo "$Description" | xargs)
    Branch=$(echo "$Branch" | xargs)
    DevName=$(echo "$DevName" | xargs)
    Priority=$(echo "$Priority" | xargs)
    GitHubURL=$(echo "$GitHubURL" | xargs)

    # Commit message template (including GitHub URL)
    COMMIT_MSG="BugID:$BugID CurrrntDateTime:$(date '+%Y-%m-%d %H:%M:%S') Branch:$Branch DevName:$DevName Priority:$Priority GitHubURL:$GitHubURL Excel Description:$Description"

    # Create a git commit
    git add .
    git commit -m "$COMMIT_MSG"
    
    # Push the changes to the correct branch and capture the result
    git push origin "$Branch"
    if [ $? -eq 0 ]; then
        echo "Push to branch $Branch was successful for BugID $BugID"
    else
        echo "Error: Push to branch $Branch failed for BugID $BugID"
        exit 1
    fi

done

