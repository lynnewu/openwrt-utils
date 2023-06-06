#!/bin/bash
tail -f /var/log/messages | grep "\[banIP" | xargs -L 1 -I {}  /src/openwrt-utils/check-banip-ports.sh {} | tee -a /var/log/banip-probes.log

