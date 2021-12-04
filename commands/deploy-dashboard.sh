#!/bin/bash
set -o allexport; source /root/.env; set +o allexport

curl -s https://codeload.github.com/imega-webrx/dashboard/zip/main -o /root/dashboard.zip || exit 1
unzip -x /root/dashboard.zip
rm /root/dashboard.zip
cd /root/dashboard-main

npm ci

rm -rf /srv/dashboard/*
mv /root/dashboard-main/* /srv/dashboard/
rm -rf /root/dashboard-main

pm2 del /srv/dashboard/ecosystem.config.js
pm2 start /srv/dashboard/ecosystem.config.js

STATUS=$(pm2 jlist | jq -r '.[] | {"name": .name, "status": .pm2_env.status} | select(.name=="dashboard") | .status')

TEXT="<b>Dashboard deployment is completed<b>"
NL="%0A"

if [ "$STATUS" == "errored" ]; then
    LOG=$(pm2 logs --raw --nostream dashboard)
    TEXT="${TEXT} - <b>Fail</b>${NL}${LOG}"
else
    TEXT="${TEXT} - Ok"
fi

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    --output /dev/null \
    -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
    -d chat_id=$CHAT_GROUP -d parse_mode=HTML -d text="${TEXT}"
