#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"


checkForRoot
checkOS
updateServer
checkOrInstallPackages "0"
setupDB
