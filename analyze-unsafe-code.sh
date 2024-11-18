#!/bin/bash

: ${GH_PR_ID:="109896"} # PR to analyze

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
    git fetch origin && git checkout main && git pull origin main && git clean -ffddxx
    popd
fi

if [ ! -d "UnsafeCodeAnalyzer" ]; then
  git clone --no-tags --single-branch --quiet https://github.com/EgorBo/UnsafeCodeAnalyzer.git
else
    pushd UnsafeCodeAnalyzer
    git fetch origin
    git checkout main
    git pull origin main
    git clean -ffddxx
    popd
fi

dotnet run -c Release --project UnsafeCodeAnalyzer/src/UnsafeCodeAnalyzer.csproj -- analyze --dir runtime --report before.md --preset DotnetRuntimeRepo

pushd runtime
# Fetch PR
CURRENT_MAIN=$(git rev-parse HEAD)
BRANCH_NAME=PR_BRANCH_$GH_PR_ID_$RANDOM
git fetch origin pull/$GH_PR_ID/head:${BRANCH_NAME}
git switch ${BRANCH_NAME}
git clean -ffddxx
git rebase --onto $CURRENT_MAIN main || true
git clean -ffddxx
popd

dotnet run -c Release --project UnsafeCodeAnalyzer/src/UnsafeCodeAnalyzer.csproj -- analyze --dir runtime --report after.md --preset DotnetRuntimeRepo
dotnet run -c Release --project UnsafeCodeAnalyzer/src/UnsafeCodeAnalyzer.csproj -- compare --base before.md --diff after.md --output report_changes.md --only-changes true
dotnet run -c Release --project UnsafeCodeAnalyzer/src/UnsafeCodeAnalyzer.csproj -- compare --base before.md --diff after.md --output report_full.md --only-changes false
