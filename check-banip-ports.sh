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

#  In order to parse log messages, we need to fix the syslog-ng message format, as such:
#
#  /etc/syslog-ng.conf
#
#destination messages { file("/var/log/messages"        template(template_date_format)); };
#
#  /etc/syslog-ng.d/syslog-ng.conf
#
#template template_date_format {
#    template("DATE=${YEAR}-${MONTH}-${DAY} TIME=${HOUR}:${MIN}:${SEC} HOST=${HOST} ${MSGHDR}${MSG}\n");
#    template_escape(no);
#};



if [ $# -eq 0 ];
then
        #  No args?  Punt without a message since this is generally only run by another script/command
        exit 1
fi

#echo ----------------------------------------------------------------

logRecord="$1"
#echo "Parsing: $1"

#
#  Create an associative array of key=value pairs from the log entry
#  Then we'll just use the keys we're interested in
#
while read -r -a words; do                # iterate over lines of input
  declare -A vars=( )                  # refresh variables for each line
  set -- "${words[@]}"                 # update positional parameters
  for word; do
    if [[ $word = *"="* ]]; then       # if a word contains an "="...
       vars[${word%%=*}]=${word#*=}    # ...then set it as an associative-array key
#printf "%s\n" $word
    fi
  done
done <<<"$logRecord"

#printf "logRecord -> %s\n"  "$logRecord"

dt=${vars[DATE]}
#echo "date: $dt"
tm=${vars[TIME]}
#echo "time: $tm"
timestamp="${dt} ${tm}"
#echo "datetime: $timestamp"

protocol=${vars[PROTO]}
#echo "protocol: $protocol"

destPort="${vars[DPT]}"
#
#  Note: relies on the nmap services file.  Either install nmap or download nmap-services from somewhere
#
#destSvc=$(grep -i "\s${destPort}/${proto}" /etc/services | cut -f 1)
#if [ -z "$destSvc" ]; then
#        destSvc="unknown"
#fi
#echo "destSvc: $destSvc"

srcAddr="${vars[SRC]}"
#echo "srcAddr: $srcAddr"

#srcHostname=`dig +short -x $srcAddr | cut -d$'\n' -f 0`
srcHostname=`dig +short -x $srcAddr | tail -1 `
#  use the parameter expansion % operator to trim the trailing "."
srcHostname="${srcHostname%.}"
#echo "SrcHost: ${srcHostname%.}"

if [ -z "$srcHostname" ]; then
        srcHostname="no_reverse_DNS"
fi
#echo "srcHostname: $srcHostname"

#outFormat="%-8s%-18s%-60s%-16s %-4s\n"
#outFormat="%-8s,%-18s,%-60s,%-16s,%-4s\n"
#outFormat="%s,%s,%s,%s,%s\n"
#outFormat="%s \t%s \t%s \t%s \t%s\n\n"
#printf "$outFormat" $destPort $destSvc $srcHostname $srcAddr $protocol
#printf "%s, %s, %s, %s, %s \n"  $destSvc $destPort $srcHostname $srcAddr $protocol
#printf "%s, %s, %s, %s, %s, \"%s\"\n"  $protocol $srcHostname $srcAddr $destPort $destSvc """$logRecord"""
#printf "%s, %s, %s, %s, %s\n"  $protocol $srcHostname $srcAddr $destPort $destSvc

#  tab-separated
outFormat="%s %s\t%s\t%s\t%s\t%s\n"
#  CSV
outFormat='"%s %s","%s","%s","%s","%s"\n'
printf "$outFormat" $timestamp $destPort $srcHostname $srcAddr $protocol
