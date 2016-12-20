#!/bin/bash
dots() {
    local pad=$(printf "%0.1s" "."{1..60})
    printf " * %s%*.*s" "$1" 0 $((60-${#1})) "$pad"
    return 0
}
updateServer() {
    dots "Updating system, this could take a while"
    local useYum=$(command -v yum)
    local useDnf=$(command -v dnf)
    if [[ -e "$useDnf" ]]; then
        dnf update -y > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Updated" || echo "Failed"
    elif [[ -e "$useYum" ]]; then
        yum update -y > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Updated" || echo "Failed"
    else
        echo "Failed"
        return 1
    fi
}
checkOS() {
    dots "Checking for compatible OS"
    if [[ -e "/etc/os-release" ]]; then
        source "/etc/os-release"
        if [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" ]]; then
            echo "$ID"
        else
            echo "$ID is incompatible"
            exit
        fi
    else
        echo "Could not determine OS"
        exit
    fi
}
installRemiAndEpel() {
    dots "Ensuring Remi and Epel repos are installed"

    local useYum=$(command -v yum)
    local useDnf=$(command -v dnf)

    if [[ "$ID" == "fedora" ]]; then
        if [[ -e "$useDnf" ]]; then
            dnf install http://rpms.remirepo.net/fedora/remi-release-${VERSION_ID}.rpm -y > /dev/null 2>&1
            dnf config-manager --set-enabled remi-php70 > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        elif [[ -e "$useYum" ]]; then
            yum install http://rpms.remirepo.net/fedora/remi-release-${VERSION_ID}.rpm -y > /dev/null 2>&1
            yum config-manager --set-enabled remi-php70 > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    elif [[ "$ID" == "centos" ]]; then
        if [[ -e "$useDnf" ]]; then
            dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERSION_ID}.noarch.rpm -y > /dev/null 2>&1
            dnf install http://rpms.remirepo.net/enterprise/remi-release-${VERSION_ID}.rpm -y > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        elif [[ -e "$useYum" ]]; then
            yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERSION_ID}.noarch.rpm -y > /dev/null 2>&1
            yum install http://rpms.remirepo.net/enterprise/remi-release-${VERSION_ID}.rpm -y > /dev/null 2>&1
            checkOrInstallPackage "yum-utils" "1"
            yum-config-manager --enable remi-php70 > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    elif [[ "$ID" == "rhel" ]]; then
        if [[ -e "$useDnf" ]]; then
            dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERSION_ID}.noarch.rpm -y > /dev/null 2>&1
            dnf install http://rpms.remirepo.net/enterprise/remi-release-${VERSION_ID}.rpm -y > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        elif [[ -e "$useYum" ]]; then
            yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERSION_ID}.noarch.rpm -y > /dev/null 2>&1
            yum install http://rpms.remirepo.net/enterprise/remi-release-${VERSION_ID}.rpm -y > /dev/null 2>&1
            checkOrInstallPackage "yum-utils" "1"
            subscription-manager repos --enable=rhel-${VERSION_ID}-server-optional-rpms > /dev/null 2>&1
            yum-config-manager --enable remi-php70 > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    fi
}
checkOrInstallPackage() {
    local package="$1"
    local silent="$2"
    local packageLocation=""
    if [[ "$silent" -eq 0 ]]; then
        dots "Installing package $package"
    fi
    local useYum=$(command -v yum)
    local useDnf=$(command -v dnf)
    if [[ -e "$useDnf" ]]; then
        dnf install "$package" -y > /dev/null 2>&1
        if [[ "$silent" -eq 0 ]]; then
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    elif [[ -e "$useYum" ]]; then
        yum install "$package" -y > /dev/null 2>&1
        if [[ "$silent" -eq 0 ]]; then
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    else
        #Unable to determine repo manager.
        if [[ "$silent" -eq 0 ]]; then
            echo "Unable to determine repo manager."
        fi
        return 1
    fi
}
setTimezone() {
    local serverTimeZone="$1"
    dots "Setting Timezone"
    timedatectl set-timezone $serverTimeZone
    [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
}
checkForRoot() {
    dots "Checking if I am root"
    currentUser=$(whoami)
    if [[ "$currentUser" == "root" ]]; then
        echo "I am $currentUser"
    else
        echo "I am $currentUser"
        exit
    fi

}
startAndEnableService() {
    local useSystemctl=$(command -v systemctl)
    local useService=$(command -v service)
    local theService="$1"
    dots "Restarting and enabling $theService"
    if [[ "$theService" == "mysql" || "$theService" == "mariadb" ]]; then
        local doMysqlAndMariadb="1"
    fi
    if [[ -e "$useSystemctl" ]]; then
        if [[ ! "$doMysqlAndMariadb" -eq 1 ]]; then
            systemctl enable $theService > /dev/null 2>&1
            systemctl restart $theService > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
        else
            systemctl enable mysql > /dev/null 2>&1
            systemctl restart mysql > /dev/null 2>&1
            local mysqlTry=$?
            systemctl enable mariadb > /dev/null 2>&1
            systemctl restart mariadb > /dev/null 2>&1
            local mariadbTry=$?
            [[ "$mysqlTry" -eq 0 || "$mariadbTry" -eq 0 ]] && echo "Ok" || echo "Failed"
        fi
    elif [[ -e "$useService" ]]; then
        if [[ ! "$doMysqlAndMariadb" -eq 1 ]]; then
            service $theService enable  > /dev/null 2>&1
            service $theService restart > /dev/null 2>&1
            [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
        else
            service mysql enable > /dev/null 2>&1
            service mysql restart > /dev/null 2>&1
            local mysqlTry=$?
            service mariadb enable > /dev/null 2>&1
            service mariadb restart > /dev/null 2>&1
            local mariadbTry=$?
            [[ "$mysqlTry" -eq 0 || "$mariadbTry" -eq 0 ]] && echo "Ok" || echo "Failed"
        fi
    else
        echo "Unable to determine service manager"
    fi
}
setupFirewalld() {
    dots "Configure firewalld"
    #To remove services allowed through firewall, use the below line:
    #for service in http samba ntp; do firewall-cmd --permanent --zone=public --remove-service=$service; done > /dev/null 2>&1
    for service in http samba ntp; do firewall-cmd --permanent --zone=public --add-service=$service; done > /dev/null 2>&1
    local useSystemctl=$(command -v systemctl)
    local useService=$(command -v service)
    if [[ -e "$useSystemctl" ]]; then
        systemctl restart firewalld > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    elif [[ -e "$useService" ]]; then
        service firewalld restart > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    else
        echo "Failed"
    fi
}
setupDB() {
    dots "Checking for jane database"
    janeDBExists=$(mysql -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'jane'")
    if [[ "$janeDBExists" != "jane" ]]; then
        echo "Does not exist"
        dots "Creating jane database"
        mysql < dbcreatecode.sql > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
        dots "Storing existing users and groups"
        php $cwd/../service/initialStoreLocalUsersAndGroups.php  > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    else
        echo "Exists"
    fi
}
