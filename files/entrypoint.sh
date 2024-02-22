#!/bin/sh
# vim:sw=4:ts=4:et

set -e

if [ "$1" = "sslocal" -o "$1" = "ssserver" -o "$1" = "ssmanager" -o "$1" = "ssservice" ]; then
    if [ -f "/etc/shadowsocks-rust/config.json" ]; then
        echo >&3 "$0: configuration file found, ready for start up"
    else
        echo >&3 "$0: no configuration files found, copy default configuration and ready for start up"
        cp /root/config.json /etc/shadowsocks-rust/config.json
    fi
fi

exec "$@"
