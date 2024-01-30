#!/usr/bin/env bash
# Exit on error
# exit when any command fails
set -e
set -o pipefail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR

# - Actual script
STAGED_FILES=`git diff --name-only --cached --diff-filter=d`
echo "Staged files ${STAGED_FILES}"

# Build edit string, by replacing newlines with semicolons.
# --diff-filter=d only filters files that are not deleted, which means we won't have trouble adding them afterwards
INCLUDE_STRING=`git diff --name-only --cached --diff-filter=d | sed ':a;N;$!ba;s/\n/;/g'`
echo "Include string: $INCLUDE_STRING"

# If the include string is empty, we're done. This happens e.g. if the commit only consists of deleted files.
if [[ -z "$INCLUDE_STRING" ]]
then
    echo "No files to change"
    exit 0
fi

# Edit your project files here
echo "Formatting files..."
SOLUTION_FILE=$(find . -type f -name "*.sln")
DOTSETTING_FILE=$(find . -type f -name "*.DotSettings*")

echo "SOLUTION_FILE: '$SOLUTION_FILE'"

if [[ ! -z "$SOLUTION_FILE" && "$OSTYPE" == "msys"* ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    ./.git/hooks/resharper/cleanupcode.exe --settings="$DOTSETTING_FILE" $SOLUTION_FILE --include="$INCLUDE_STRING"
elif [[ ! -z "$SOLUTION_FILE" && "$OSTYPE" == "cygwin" ]]; then
    # Cygwin terminal emulator
    ./.git/hooks/resharper/cleanupcode.exe --settings="$DOTSETTING_FILE" $SOLUTION_FILE --include="$INCLUDE_STRING"
elif [[ ! -z "$SOLUTION_FILE" ]]; then
    sh ./.git/hooks/resharper/cleanupcode.sh --settings="$DOTSETTING_FILE" $SOLUTION_FILE --include="$INCLUDE_STRING"
else 
    echo "Solution not found"
fi

# Restage files
echo "Restaging files: $STAGED_FILES"
echo ${STAGED_FILES} | xargs -t -l git add

echo "pre-commit hook finished"
