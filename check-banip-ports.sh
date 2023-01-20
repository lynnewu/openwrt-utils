#!/bin/bash
#
#  License: https://directory.fsf.org/wiki/License:Apache-2.0
#
#  Usage: 'tail -f /var/log/messages | grep -i banip | xargs -L 1 -I {} $0 {}'"
#
#  Author:  lynne.whitehorn@gmail.com
#
#  Requirements:
#    OpenWRT v19.07 (at least)
#    banIP - https://forum.openwrt.org/t/banip-support-thread/16985
#    nmap - v7.7 (at least, but it only uses the port/services definitions file, so the version might not matter at all)
#

#
# tail -f /var/log/messages | grep -i banip | xargs -L1 -I {} ./check-banip-ports.sh {}
#

if [ $# -eq 0 ];
then
        #  No args?  Punt without a message since this is generally only run by another script/command
        exit 1
fi

#echo ----------------------------------------------------------------

logRecord="$1"
#echo "Parsing: $1"

#  create an associative array
while read -r -a words; do                # iterate over lines of input
  declare -A vars=( )                  # refresh variables for each line
  set -- "${words[@]}"                 # update positional parameters
  for word; do
    if [[ $word = *"="* ]]; then       # if a word contains an "="...
       vars[${word%%=*}]=${word#*=}    # ...then set it as an associative-array key
    fi
  done
done <<<"$logRecord"

protocol="${vars[PROTO]}"
#echo "protocol: $protocol"

destPort="${vars[DPT]}"
#echo "destPort: $destPort"

#
#  Note: relies on the nmap services file.  Either install nmap or download nmap-services from somewhere
#
destSvc=$(grep -i "\s${destPort}/${proto}" /etc/services | cut -f 1)
if [ -z "$destSvr" ]; then
        destSvc="unknown"
fi
#echo "destSvc: $destSvc"

srcAddr="${vars[SRC]}"
#echo "srcAddr: $srcAddr"

srcHostname=`dig +short -x $srcAddr`
if [ -z "$srcHostname" ]; then
        srcHostname="<none>"
fi
#echo "srcHostname: $srcHostname"

#printf "\n"

#echo prot:$protocol,port:$destPort,svc:$destSvc,src:$srcAddr,fqdn:$srcHostname
echo $protocol,$srcHostname,$srcAddr,$destPort,$destSvc
