#!/bin/sh
# this is an example of how you can use this
# this can work in kubernetes or podman 
# this example uses docker 
mkdir /opt/discordprinter
cd /opt/discordprinter


read -p "Enter Discord Webhook URL: " webhookurl
read -p "Enter The Team Number (1 .. 30 etc): " teamnum

cat <<EOF > printer.conf
WEBHOOK="${webhookurl}"
TEAM_NUM="${teamnum}"
EOF

wget https://raw.githubusercontent.com/wrccdc-org/discord-printer/main/docker-compose.yaml
docker-compose pull
docker-compose up -d 
# if you want to validate everything you can do docker-compose up and the debug output will validate everything
