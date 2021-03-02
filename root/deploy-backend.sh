#!/bin/bash
set -o allexport; source .env; set +o allexport

curl -s https://codeload.github.com/imega-webrx/backend/zip/master -o /root/backend.zip || exit 1

unzip -x /root/backend.zip

rm /root/backend.zip

cd /root/backend-master

npm ci

rm -rf /srv/backend/*

mv /root/backend-master/* /srv/backend/

pm2 del /srv/backend/ecosystem.config.js

pm2 start /srv/backend/ecosystem.config.js

rm -rf /root/backend-master

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage -d chat_id=$CHAT_GROUP -d text="backend deployment is completed."
