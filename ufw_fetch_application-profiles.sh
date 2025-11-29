#!/bin/bash

## script-commons:
scriptsCommonUtilities=$(mktemp)
curl -fsSL -o "$scriptsCommonUtilities" https://gitlab.com/bertrand-benoit/scripts-common/-/raw/master/utilities.sh
. "$scriptsCommonUtilities"
BSC_VERBOSE=1
## :script-commons

checkBin curl || errorMessage "This snippet requires curl. Install it please, and then run this tool again."

runDateTime=$(getFormattedDatetime '%Y-%m-%d-%H-%M-%S')
echo "---" >/tmp/ufw_fetch_application-profile.sh.log
echo "$runDateTime" >>/tmp/ufw_fetch_application-profile.log
echo "---" >>/tmp/ufw_fetch_application-profile.log

info "Starting..."

export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive

profileNames=(
  "AIM"
  "Alertmanager"
  "Bind9"
  "Bonjour"
  "CIFS"
  "CUPS"
  "Deluge"
  "dhcp"
  "dhcp6"
  "distcc"
  "DNS"
  "Dovecot"
  "Dropbox"
  "elasticsearch"
  "grafana"
  "http"
  "imap"
  "Kerberos"
  "kibana"
  "L2TP"
  "ldap"
  "logstash"
  "LPD"
  "MongoDB"
  "mosh"
  "MySQL"
  "nfs"
  "NTP"
  "OpenVPN"
  "OSSEC"
  "PeopleNearby"
  "plexmediaserver"
  "Polipo"
  "POP3"
  "POP3S"
  "PostgreSQL"
  "PPTP"
  "Prometheus"
  "Proxy"
  "qbittorrent"
  "RDP"
  "README".md
  "redis"
  "Samba"
  "SIP"
  "SMTP"
  "SNMP"
  "Socks"
  "spamd"
  "ssh"
  "submission"
  "syncthing"
  "Synergy"
  "syslog"
  "Telnet"
  "TFP"
  "Tor"
  "Transmission"
  "VNC"
  "whois"
  "wsdd"
  "XMPP"
  "Yahoo"
)

for f in $profileNames; do
    remoteUrl="https://raw.githubusercontent.com/f4bio/ufw-application-profiles/refs/heads/develop/applications.d/$f"

    getURLContents $remoteUrl /etc/ufw/applications.d/$f
done

info "All Done!"
