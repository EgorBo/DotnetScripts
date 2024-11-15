#!/bin/bash

: ${GH_PR_ID:="108365"} # PR to analyze

# Install local dotnet
wget -O dotnet-installer.sh \
https://raw.githubusercontent.com/EgorBo/DotnetScripts/refs/heads/main/dotnet-installer.sh && \
chmod +x dotnet-installer.sh
source dotnet-installer.sh
installDotnet 8.0
installDotnet 9.0
#

git clone --no-tags --single-branch --quiet https://github.com/dotnet/runtime.git
git clone --no-tags --single-branch --quiet https://github.com/EgorBo/UnsafeCodeAnalyzer.git

pushd UnsafeCodeAnalyzer
dotnet build -c Release
dotnet run -c Release -v q -- ../runtime before.csv -quite > ../before.txt
popd

pushd runtime
# Fetch PR
git fetch origin pull/$GH_PR_ID/head:PR_BRANCH
git switch PR_BRANCH
git clean -ffddxx # Remove all untracked files and directories
popd

pushd UnsafeCodeAnalyzer
dotnet run -c Release -v q -- ../runtime pr.csv -quite > ../after.txt
popd

echo ""
echo "------"
echo "Base results:"
echo "$(cat before.txt)"
echo "------"
echo "PR results:"
echo "$(cat after.txt)"


if [ -z "$EGORBOT_SERVER" ]; then
  echo "EGORBOT_SERVER is not set. Skipping sending results to the server."
  exit 0
fi
curl -k -X POST $EGORBOT_SERVER?jobId=$EGORBOT_JOBID -F "file=@before.txt" -F "file=@after.txt"
