#!/bin/bash

cat <<EOF

Welcome!

To configure this printer you will need to do a couple of things:
1. Get a websocket token from your Discord channel (this comes as part of your team packet)
2. Create a file called printer.conf with the following contents
	WEBHOOK="<<<WEBHOOK HERE>>>"
	TEAM_NUM="<<< TEAM NUMBER HERE >>"
3. Create a volume mount (this should already be done as part of the docker compose) 
   from printer.conf on the host to /opt/printer.conf in the container
4. Run docker-compose up if you're using docker-compose. Otherwise just a standard docker command will do.
5. Ensure webhook runs by doing ./print.sh ./readme.txt

Optional (but recommended): Secure CUPS so not everyone is full admin

EOF


echo "Beginning Tests..."

/opt/printer.sh test


if [ -x /usr/sbin/cupsd ]; then
	echo "Starting core services..."
	busybox syslogd -O /var/log/syslog
	touch /var/log/syslog; chmod 777 /var/log/syslog
	/etc/init.d/dbus start
	/etc/init.d/avahi-daemon start
	/etc/init.d/cups start
else
	echo "Error: CUPS is missing!"
	exit 1
fi

while true; do
	ippeveprinter -M "DiscordPrinter" -m "DiscordPrinter" -l "The Data Center" -s "10,2" -f "application/pdf,image/jpeg,image/pwg-raster" -i /opt/logo.png -p 1631 -c /opt/printer.sh -k -d /var/spool/pdf --no-web-forms -r off -v DiscordPrinter
	sleep 30
done
