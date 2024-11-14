```bash
wget -O dotnet-installer.sh \
https://raw.githubusercontent.com/EgorBo/DotnetScripts/refs/heads/main/dotnet-installer.sh && \
chmod +x dotnet-installer.sh && source dotnet-installer.sh

# installDotnet "version" "folder (optional)"
installDotnet 8.0
installDotnet 9.0

# Validate the installation
echo "dotnet version: $(dotnet --version)"
echo "dotnet location: $(which dotnet)"
```
