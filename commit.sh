#!/bin/bash

# Path to the CSV file
CSV_FILE="bugs.csv"

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
  echo "Error: CSV file '$CSV_FILE' not found."
  exit 1
fi

# Read data from the CSV
while IFS=',' read -r BugID Description Branch DevName Priority; do
    # Skip the header row
    if [ "$BugID" == "BugID" ]; then
        continue
    fi
    
    # Ensure that required fields are not empty
    if [ -z "$BugID" ] || [ -z "$Description" ] || [ -z "$Branch" ] || [ -z "$DevName" ] || [ -z "$Priority" ]; then
        echo "Error: Missing required field in CSV."
        exit 1
    fi
    
    # Commit message template
    COMMIT_MSG="BugID:$BugID CurrrntDateTime:$(date '+%Y-%m-%d %H:%M:%S') Branch:$Branch DevName:$DevName Priority:$Priority Excel Description:$Description"

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
done < "$CSV_FILE"
