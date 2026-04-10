#!/bin/bash

command -v curl >/dev/null 2>&1 || { echo >&2 "This snippet requires curl. Install it please, and then run this tool again."; exit 1; }

runDateTime=$(date '+%Y-%m-%d-%H-%M-%S')
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

for f in "${profileNames[@]}"; do
  remoteUrl="https://raw.githubusercontent.com/f4bio/ufw-application-profiles/refs/heads/develop/applications.d/$f"

  curl -fsSL -o /etc/ufw/applications.d/$f $remoteUrl
done

info "All Done!"
