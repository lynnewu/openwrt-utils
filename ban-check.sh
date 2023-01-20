#  todo:  fix all this
tail -f /var/log/messages | grep -i banip | xargs -L 1 -I {} /src/openwrt-utils/check-banip-ports.sh {} | tee banip-probes.log
