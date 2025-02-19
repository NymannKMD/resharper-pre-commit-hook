#!/usr/bin/env bash
# Exit on error
# exit when any command fails
set -e
set -o pipefail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR

outFile="./resharper-cli.zip"
gitResharperFolder="./.git/hooks/resharper"
preCommitFile="./.git/hooks/pre-commit"
cliUrl="https://download.jetbrains.com/resharper/dotUltimate.2023.3.3/JetBrains.ReSharper.CommandLineTools.2023.3.3.zip?_gl=1*hi8i2b*_ga*MTg2OTE0MzMzNi4xNzA2NjQzMjQw*_ga_9J976DJZ68*MTcwNjY0MzI0MC4xLjEuMTcwNjY0MzYzMy40My4wLjA.&_ga=2.37106208.1254910719.1706643247-1869143336.1706643240"
preCommitHookUrl="https://raw.githubusercontent.com/NymannKMD/resharper-pre-commit-hook/master/pre-commit-hook.sh"


echo "Fetching Resharper CLI tools"
curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" "${cliUrl}" > ${outFile}

echo "Cleaning up old versions"
rm -rf ${gitResharperFolder} # Delete any old versions
mkdir -p ${gitResharperFolder}
echo "Extracting into ${gitResharperFolder}"
unzip -o "./${outFile}" -d ${gitResharperFolder}

echo "Adding pre-commit hook"
curl -s ${preCommitHookUrl} > ${preCommitFile}

echo "Marking as executable"
chmod u+x ${preCommitFile}


echo "Cleaning up..."
rm -f ${outFile}
