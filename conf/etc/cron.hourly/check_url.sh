#!/bin/bash
set -o allexport; source /root/.env; set +o allexport

TEXT="<b>Check services:</b>"
NL="%0A"

assert() {
    TEXT="${TEXT}${NL}$3"

    if [ "$1" != "$2" ]; then
        TEXT="${TEXT}<b>Fail</b>"
    else
        TEXT="${TEXT}Ok"
    fi
}

ACTUAL=$(curl --write-out %{http_code} --silent --output /dev/null https://webrx.ru)
assert 200 $ACTUAL "webrx.ru - "

ACTUAL=$(curl --write-out %{http_code} --silent --output /dev/null https://webrx.ru/playground)
assert 200 $ACTUAL "webrx.ru/playground - "

ACTUAL=$(curl --write-out %{http_code} --silent --output /dev/null https://webrx.ru/dashboard)
assert 200 $ACTUAL "webrx.ru/dashboard - "

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    --output /dev/null \
    -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
    -d chat_id=$CHAT_GROUP -d parse_mode=HTML -d text="${TEXT}"
