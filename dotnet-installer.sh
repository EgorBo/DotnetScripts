#!/bin/sh

# A wrapper over dotnet-install.sh script

function installDotnet () {
    DOTNET_VERSION="${1:-8.0}"
    export DOTNET_ROOT="${2:-$(pwd)/dotnet}"
    if [ ! -f "${DOTNET_ROOT}/dotnet-install.sh" ]; then
        mkdir -p ${DOTNET_ROOT}
        echo "Downloading dotnet-install.sh script into ${DOTNET_ROOT}"
        wget https://dot.net/v1/dotnet-install.sh -O ${DOTNET_ROOT}/dotnet-install.sh
        chmod +x ${DOTNET_ROOT}/dotnet-install.sh
    fi
    ${DOTNET_ROOT}/./dotnet-install.sh -Channel $DOTNET_VERSION -InstallDir ${DOTNET_ROOT}
    if [ "$(which dotnet)" != "${DOTNET_ROOT}/dotnet" ]; then
        export PATH=${DOTNET_ROOT}:${DOTNET_ROOT}/tools:${PATH}
    fi
}
