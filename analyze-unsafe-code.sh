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
dotnet build
dotnet run -c Release -v q -- ../runtime base.csv > ../base.txt
popd

pushd runtime
# Fetch PR
git fetch origin pull/$GITHUB_PR/head:PR_BRANCH
git switch PR_BRANCH
git clean -ffddxx # Remove all untracked files and directories
popd

pushd UnsafeCodeAnalyzer
dotnet run -c Release -v q -- ../runtime pr.csv > ../pr.txt
popd

echo ""
echo "------"
echo "Base results:"
echo "$(cat base.txt)"
echo "------"
echo "PR results:"
echo "$(cat pr.txt)"
