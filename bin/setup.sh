#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"


checkForRoot
checkOS
updateServer
checkOrInstallPackages "0"
setupDB
placeFiles

echo ' '
echo ' '
echo 'Default user:pass is:'
echo 'user'
echo 'changeme'
echo ' '
