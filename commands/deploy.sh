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
rm -rv /root/deploy
mv -v /root/tmp/deploy-master /root/deploy
chmod +x -R /root/deploy/commands
rm -rv /root/tmp

diff -q /root/deploy/lib/systemd/system/webhook.service \
    /lib/systemd/system/webhook.service || \
    {
        echo "Update /lib/systemd/system/webhook.service";
        TEXT="${TEXT}${NL}Update: /lib/systemd/system/webhook.service - "
        cp -v /root/deploy/lib/systemd/system/webhook.service \
            /lib/systemd/system/webhook.service && \
            TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"

        echo "Reload systemd"
        TEXT="${TEXT}${NL}Reload systemd: "
        systemctl daemon-reload && TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
    }

# systemctl restart webhook

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
    -d chat_id=$CHAT_GROUP -d parse_mode=HTML -d text="${TEXT}"
