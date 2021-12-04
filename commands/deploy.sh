#!/bin/bash
set -o allexport; source .env; set +o allexport

mkdir -pv /root/deploy /root/tmp
cd /root/tmp
curl -s https://codeload.github.com/imega-webrx/deploy/zip/master \
    -o /root/tmp/deploy.zip || exit 1

unzip -x /root/tmp/deploy.zip
rm -v /root/tmp/deploy.zip

echo 22223

rm -rv /root/deploy
mv -v /root/tmp/deploy-master /root/deploy

echo 11111

chmod +x -R /root/deploy/commands

# systemctl restart webhook

rm -rv /root/tmp

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -d chat_id=$CHAT_GROUP -d text="deploy deployment is completed."
