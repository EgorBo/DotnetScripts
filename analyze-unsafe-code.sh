#!/bin/bash

: ${GITHUB_PR:="108365"} # PR to analyze

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
dotnet run -c Release -v q -- ../runtime base.csv -quite > ../base.txt
popd

pushd runtime
# Fetch PR
git fetch origin pull/$GITHUB_PR/head:PR_BRANCH
git switch PR_BRANCH
git clean -ffddxx # Remove all untracked files and directories
popd

pushd UnsafeCodeAnalyzer
dotnet run -c Release -v q -- ../runtime pr.csv -quite > ../pr.txt
popd

echo ""
echo "------"
echo "Base results:"
echo "$(cat base.txt)"
echo "------"
echo "PR results:"
echo "$(cat pr.txt)"


if [ -z "$EGORBOT_SERVER" ]; then
  echo "EGORBOT_SERVER is not set. Skipping sending results to the server."
  exit 0
fi
curl -X POST -H "Content-Type: application/json" -d '{"PrNum": $GITHUB_PR,  "Before": "$(cat base.txt)", "After": "$(cat pr.txt)"}' $EGORBOT_SERVER
