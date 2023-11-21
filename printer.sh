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

# this won't work because docker is read only...
#sed -i "s/ //g" "${PRINTER_CONF_PATH}"

source "${PRINTER_CONF_PATH}"

if [ -z "${WEBHOOK}" -o -z "${TEAM_NUM}" ]; then
	dolog "printer.sh error either WEBHOOK or TEAM_NUM are not defined in configuration!"
	exit 1
fi

dolog "found TEAM_NUM envvar"
dolog "found WEBHOOK envvar"

dolog "has identified team as: ${TEAM_NUM}"

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
	if [ -z "$3" ]; then
			sender="unknown"
	fi
	teaminf="(Team ${TEAM_NUM})"


	if [ $((RANDOM%50)) -eq 0 ]; then
		message="**Discord Printer** is *jammed*! Try printing again... https://i.imgur.com/VYwZURV.gif"
	else 
		message="**Discord Printer** recieved a new document and has made it available for you to download.   (Sender:   ${sender}) ${teaminf}"
	fi

	$DISCORDCMD \
		--file "${PDFNAME}" \
		--webhook-url="$WEBHOOK" \
		--username "DiscordPrinter" \
		--text "${message}" \
		--avatar "https://i.imgur.com/0R30ZZ5.png" \
		--timestamp
	logger "printer.sh completed printer job at $DST"
	if [ "$FIXPRINT" -eq 1 ]; then
		rm "${PDFNAME}"
	fi  
fi
exit 0

