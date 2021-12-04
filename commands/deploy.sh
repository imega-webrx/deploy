#!/bin/bash -x
set -o allexport; source /root/.env; set +o allexport

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

chmod +x -R /root/deploy/conf/etc/cron.hourly
cp -v /root/deploy/conf/etc/cron.hourly/check_url.sh /etc/cron.hourly

RELOAD_SYSTEMCTL=false
diff -q /root/deploy/conf/lib/systemd/system/webhook.service \
    /lib/systemd/system/webhook.service || \
    {
        echo "Update /lib/systemd/system/webhook.service";
        TEXT="${TEXT}${NL}Update: /lib/systemd/system/webhook.service - "
        cp -v /root/deploy/conf/lib/systemd/system/webhook.service \
            /lib/systemd/system/webhook.service && \
            TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
        RELOAD_SYSTEMCTL=true
    }

diff -q /root/deploy/conf/etc/systemd/webhook \
    /etc/systemd/webhook || \
    {
        echo "Update /root/deploy/conf/etc/systemd/webhook";
        TEXT="${TEXT}${NL}Update: /etc/systemd/webhook - "
        cp -v /root/deploy/conf/etc/systemd/webhook \
            /etc/systemd/webhook && \
            TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
        RELOAD_SYSTEMCTL=true
    }

$RELOAD_SYSTEMCTL && {
    echo "Reload systemd";
    TEXT="${TEXT}${NL}Reload systemd: ";
    systemctl daemon-reload && TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
}

RELOAD_NGINX=false

diff -q /root/deploy/conf/etc/nginx/nginx.conf \
    /etc/nginx/nginx.conf || \
    {
        echo "Update /etc/nginx/nginx.conf";
        TEXT="${TEXT}${NL}Update: /etc/nginx/nginx.conf - "
        cp -v /root/deploy/conf/etc/nginx/nginx.conf \
            /etc/nginx/nginx.conf && \
            TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
        RELOAD_NGINX=true
    }

diff -q /root/deploy/conf/etc/nginx/conf.d/webrx.ru.conf \
    /etc/nginx/conf.d/webrx.ru.conf || \
    {
        echo "Update /etc/nginx/conf.d/webrx.ru.conf";
        TEXT="${TEXT}${NL}Update: /etc/nginx/conf.d/webrx.ru.conf - "
        cp -v /root/deploy/conf/etc/nginx/conf.d/webrx.ru.conf \
            /etc/nginx/conf.d/webrx.ru.conf && \
            TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
        RELOAD_NGINX=true
    }

$RELOAD_NGINX && {
    echo "Reload nginx";
    TEXT="${TEXT}${NL}Reload nginx: ";
    systemctl reload nginx && TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
}

RESTART_WEBHOOK=false
diff -q /root/deploy/conf/etc/webhook/hooks.json \
    /etc/webhook/hooks.json || \
    {
        echo "Update /etc/webhook/hooks.json";
        TEXT="${TEXT}${NL}Update /etc/webhook/hooks.json - "
        cp -v /root/deploy/conf/etc/webhook/hooks.json \
            /etc/webhook/hooks.json && \
            TEXT="${TEXT}Ok" || TEXT="${TEXT}<b>Fail</b>"
        echo "Reload webhook"
        TEXT="${TEXT}${NL}Reload webhook: Ok"
        RESTART_WEBHOOK=true
    }

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
    -d chat_id=$CHAT_GROUP -d parse_mode=HTML -d text="${TEXT}"

$RESTART_WEBHOOK && systemctl restart webhook
