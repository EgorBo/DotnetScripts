#!/bin/bash

: ${GH_PR_ID:="108365"} # PR to analyze

# Install local dotnet
wget -O dotnet-installer.sh \
https://raw.githubusercontent.com/EgorBo/DotnetScripts/refs/heads/main/dotnet-installer.sh && \
chmod +x dotnet-installer.sh
source dotnet-installer.sh
installDotnet 8.0
installDotnet 9.0

if [ ! -d "runtime" ]; then
  git clone --no-tags --single-branch --quiet https://github.com/dotnet/runtime.git
else
    pushd runtime
    git fetch origin && git checkout main && git pull
    popd
fi

if [ ! -d "UnsafeCodeAnalyzer" ]; then
  git clone --no-tags --single-branch --quiet https://github.com/EgorBo/UnsafeCodeAnalyzer.git
else
    pushd UnsafeCodeAnalyzer
    git fetch origin && git checkout main && git pull
    popd
fi

pushd UnsafeCodeAnalyzer
dotnet build -c Release
dotnet run -c Release -v q -- ../runtime ../before.md -quite > ../before.txt
popd

pushd runtime
# Fetch PR
git fetch origin pull/$GH_PR_ID/head:PR_BRANCH_$GH_PR_ID && git switch PR_BRANCH_$GH_PR_ID && git clean -ffddxx
popd

pushd UnsafeCodeAnalyzer
dotnet run -c Release -v q -- ../runtime ../after.md -quite > ../after.txt
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
curl -k -X POST $EGORBOT_SERVER?jobId=$EGORBOT_JOBID -F "file=@before.md" -F "file=@after.md"
