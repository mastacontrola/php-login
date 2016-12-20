#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"
checkForRoot
checkOS
installRemiAndEpel
updateServer
checkOrInstallPackage "mariadb" "0"
checkOrInstallPackage "mariadb-server" "0"
checkOrInstallPackage "php" "0"
checkOrInstallPackage "httpd" "0"
checkOrInstallPackage "php-mysqlnd" "0"
checkOrInstallPackage "firewalld" "0"
checkOrInstallPackage "ntp" "0"
checkOrInstallPackage "lsof" "0"
startAndEnableService "firewalld"
setupFirewalld
startAndEnableService "ntpd"
setTimezone "America/Chicago"
startAndEnableService "httpd"
startAndEnableService "mysql"
setupDB
completed
