#!/bin/bash
set -o allexport; source .env; set +o allexport

mkdir -pv /root/deploy /root/tmp
cd /root/tmp
curl -s https://codeload.github.com/imega-webrx/deploy/zip/master \
    -o /root/tmp/deploy.zip || exit 1

unzip -x /root/tmp/deploy.zip
rm /root/deploy/deploy.zip
rm -rv /root/deploy

echo 2222

mv -v /root/tmp/deploy-master /root/deploy

echo 11111

chmod +x -R /root/deploy/commands

# systemctl restart webhook

rm -rv /root/tmp

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -d chat_id=$CHAT_GROUP -d text="deploy deployment is completed."
