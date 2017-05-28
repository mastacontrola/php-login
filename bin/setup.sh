#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"


checkForRoot
checkOS
updateServer
checkOrInstallPackage "mariadb" "0"
checkOrInstallPackage "mariadb-server" "0"
checkOrInstallPackage "php" "0"
checkOrInstallPackage "httpd" "0"
checkOrInstallPackage "php-mysqlnd" "0"
startAndEnableService "httpd"
startAndEnableService "mysql"
setupDB
