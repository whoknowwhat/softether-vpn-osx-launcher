#!/bin/bash

##########################################################
# YOU MUST MODIFIED THIS CONSTANTS UPON YOUR ENVIRONMENTS
##########################################################
TARGET_IPS=(0.0.0.0 1.1.1.1)
GATEWAY=192.168.0.1

VPNCLIENT_HOME=${HOME}/Downloads/vpnclient
VPN_NAME='DEFAULT_VPN'
##########################################################

start() {
    sudo ${VPNCLIENT_HOME}/vpnclient start
    ${VPNCLIENT_HOME}/vpncmd << EOF
2
localhost
accountconnect
${VPN_NAME}
accountlist
exit
EOF
    # waiting for vpn connection is established
    sleep 10
    sudo /usr/sbin/ipconfig set tap0 DHCP
    # waiting for dhcp
    sleep 5
    # print allocated ip
    /sbin/ifconfig tap0
    for ip in ${TARGET_IPS[@]}; do
        sudo route -n add -net ${ip}/32 ${GATEWAY}
    done
}

stop() {
    ${VPNCLIENT_HOME}/vpncmd << EOF
2
localhost
accountdisconnect
${VPN_NAME}
accountlist
exit
EOF
    for ip in ${TARGET_IPS[@]}; do
        sudo route -n delete -net ${ip}/32 ${GATEWAY}
    done
    sudo ${VPNCLIENT_HOME}/vpnclient stop
}

status() {
    ${VPNCLIENT_HOME}/vpncmd << EOF
2
localhost
accountlist
exit
EOF
}

reload() {
    for ip in ${TARGET_IPS[@]}; do
        sudo route -n delete -net ${ip}/32 ${GATEWAY}
        sudo route -n add -net ${ip}/32 ${GATEWAY}
    done
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    reload)
        reload
        ;;
    *)
        echo "Usage: $0 {start|stop|status|reload}"
        exit 1
        ;;
esac