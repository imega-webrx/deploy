#!/bin/bash
set -o allexport; source /root/.env; set +o allexport

TEXT="<b>Dashboard deployment is completed</b>"
NL="%0A"

sendMessage() {
    curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
        --output /dev/null \
        -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
        -d chat_id=$CHAT_GROUP -d parse_mode=HTML -d text="$1"
}

error_handler() {
    sendMessage "$1"
}

curl -s https://codeload.github.com/imega-webrx/dashboard/zip/main -o /root/dashboard.zip || exit 1
unzip -x /root/dashboard.zip
rm /root/dashboard.zip
cd /root/dashboard-main

npm ci || error_handler "$TEXT - <b>Fail</b>"

rm -rf /srv/dashboard
mv -v /root/dashboard-main /srv/dashboard
rm -r /root/dashboard-main

pm2 del /srv/dashboard/ecosystem.config.js
pm2 start /srv/dashboard/ecosystem.config.js

sleep 10

STATUS=$(pm2 jlist | jq -r '.[] | {"name": .name, "status": .pm2_env.status} | select(.name=="dashboard") | .status')

if [ "$STATUS" == "errored" ]; then
    LOG=$(pm2 logs --raw --nostream dashboard)
    TEXT="${TEXT} - <b>Fail</b>${NL}<code>${LOG}</code>"

    error_handler "$TEXT"
else
    TEXT="${TEXT} - Ok"

    error_handler "$TEXT"
fi
