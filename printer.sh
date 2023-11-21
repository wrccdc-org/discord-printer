#!/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/discord.sh"
FIXPRINT="1"

# some day we can try: https://github.com/istopwg/ippsample/

dolog() {
	echo "* discord.sh $1"
	logger "$1"
}

# start

DISCORDCMD="/opt/discord.sh"

if [ ! -x "${DISCORDCMD}" ]; then
	dolog "path (${DISCORDCMD}) is not valid"
	exit 1
else 
	dolog "successfully found discord.sh (${DISCORDCMD})"
fi

if command -v jq &>/dev/null; then
	dolog "successfully found jq command"
else
 	dolog "unable to locate jq command"
fi

if command -v bash &>/dev/null; then
	dolog "successfully found bash command"
else
 	dolog "unable to locate bash command"
fi

if command -v curl &>/dev/null; then
	dolog "successfully found curl command"
else
 	dolog "unable to locate curl command"
fi

DISCORDPATH=$(dirname "${DISCORDCMD}")

if [ -z "${PRINTER_CONF_PATH}" -a -f "/opt/printer.conf" ]; then
	PRINTER_CONF_PATH="/opt/printer.conf"
fi

if [ -z "${PRINTER_CONF_PATH}" -a -f "${DISCORDPATH}/printer.conf" ]; then
	PRINTER_CONF_PATH="/opt/printer.conf"
fi

if [ -z "${PRINTER_CONF_PATH}" ]; then
	dolog "could not find printer configuration!"
	exit 1
fi

dolog "found printer configuration at ${PRINTER_CONF_PATH}"
 
source "${PRINTER_CONF_PATH}"

if [ -z "${WEBHOOK}" -o -z "${TEAM_NUM}" ]; then
	dolog "printer.sh error either WEBHOOK or TEAM_NUM are not defined in configuration!"
	exit 1
fi

dolog "found TEAM_NUM envvar"
dolog "found WEBHOOK envvar"

dolog "has identified team as: ${TEAM_NUM}"


echo "${WEBHOOK}"  > "${DISCORDPATH}/.webhook"


if [ -z "$1" ]; then
	dolog "error no arguments supplied, must be called by cups pdf or ippeveprinter"
	exit 1
fi

if [ "$1" == "test" ]; then
	dolog "is in test mode... no fatal errors were  found"
else
	DST="file=$1 owner = $2 [ $3 $4 ] $(date)"
	PDFNAME="$1"
	logger "printer.sh is starting print job at $DST"
	sender="$3"
	
	if [ ! -e "$1" ]; then
		dolog "error file $1 does not exist"
	else
		dolog "valid file found, attempting to send"
	fi
	
	FILESIZE=$(($(stat -c '%s' $PDFNAME)/1024))
	
	dolog "file size identified to be ${FILESIZE}"
	
	if [ -z "$3" ]; then
			sender="unknown"
	fi
	
	teaminf=""
	if [ ! -z "${TEAM_NUM}" ]; then
		teaminf="(Team ${TEAM_NUM})"
	fi

	if [ $((RANDOM%50)) -eq 0 ] || [ $FILESIZE -gt 8100 ]; then
		message="**Discord Printer** is *jammed*! Try printing again... https://i.imgur.com/VYwZURV.gif"
	else 
		message="**Discord Printer** recieved a new document and has made it available for you to download.   (Sender:   ${sender}) ${teaminf}"
	fi

	$DISCORDCMD \
		--file "${PDFNAME}" \
		--username "CCDCPrinter" \
		--text "${message}" \
		--avatar "https://i.imgur.com/0R30ZZ5.png" \
		--timestamp
	logger "printer.sh completed printer job at $DST"
	if [ "$FIXPRINT" -eq 1 ]; then
		rm "${PDFNAME}"
	fi  
fi
exit 0
