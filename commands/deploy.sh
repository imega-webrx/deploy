#!/bin/bash
set -o allexport; source .env; set +o allexport

TEXT="<b>Deploy deployment is completed</b>"
NL="%0A"

mkdir -pv /root/deploy /root/tmp
cd /root/tmp
curl -s https://codeload.github.com/imega-webrx/deploy/zip/master \
    -o /root/tmp/deploy.zip || exit 1

unzip -x /root/tmp/deploy.zip
rm -v /root/tmp/deploy.zip

diff -q /root/deploy/lib/systemd/system/webhook.service \
    /lib/systemd/system/webhook.service || \
    {
        echo "Update /lib/systemd/system/webhook.service";
        TEXT="${TEXT}${NL}Update: /lib/systemd/system/webhook.service - "
        echo "Reload systemd"
        TEXT="${TEXT}${NL}Reload systemd: "
        systemctl restart webhook && TEXT="${TEXT}Ok" || TEXT="${TEXT}Fail"
    }


rm -rv /root/deploy
mv -v /root/tmp/deploy-master /root/deploy

chmod +x -R /root/deploy/commands

# systemctl restart webhook


rm -rv /root/tmp

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
    -d chat_id=$CHAT_GROUP -d parse_mode=HTML -d text=$TEXT
