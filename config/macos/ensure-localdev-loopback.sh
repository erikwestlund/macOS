#!/usr/bin/env sh

set -eu

ip_alias="10.254.254.1"

if ! /sbin/ifconfig lo0 | /usr/bin/grep -q "$ip_alias"; then
  /sbin/ifconfig lo0 alias "$ip_alias"
fi
