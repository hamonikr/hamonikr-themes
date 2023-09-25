#!/bin/bash

readonly SCRIPT_NAME="/var/log/syslog"

log() {
  echo "$@"
  logger -p user.notice -t $SCRIPT_NAME "$@"
}

err() {
  echo "$@" >&2
  logger -p user.error -t $SCRIPT_NAME [ERROR] "$@"
}

# 하모니카OS 가 아닌 경우에만 실행
if [ ! -f "/etc/hamonikr/info" ] ; then
    if [ -f "/usr/bin/curl" ] ; then
        RD=`head -c 16 /dev/urandom | md5sum | head -c 32`
        source /etc/os-release

        if [ -z $CODENAME ] ; then
            if [ -z $VERSION_CODENAME ] ; then
                CODENAME="Unknown"
            else
                CODENAME="$VERSION_CODENAME"
            fi
        else
            CODENAME="$CODENAME-live"
        fi

        if [ -z $RELEASE ] ; then
            if [ -z $VERSION_ID ] ; then
                RELEASE="Unknown"
            else
                RELEASE="$VERSION_ID"
            fi
        fi   
        # DEBUG 
        # echo "codename=$CODENAME,version=$RELEASE value=\"$RD\""

        if ping -q -c 1 -W 1 u.hamonikr.org >/dev/null; then
            curl -XPOST "http://u.hamonikr.org:8086/write?db=hamonikr" --data-binary "machineid,codename=$CODENAME,version=$RELEASE value=\"$RD\""
            log "Update theme using count"
            # echo "Update theme using count"
        else
            err "Not found : u.hamonikr.org"        
        fi   

    fi    

fi