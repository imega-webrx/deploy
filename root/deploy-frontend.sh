#!/bin/bash
set -o allexport; source .env; set +o allexport

curl -s https://codeload.github.com/imega-webrx/frontend/zip/master -o /root/frontend.zip || exit 1

unzip -x /root/frontend.zip

rm /root/frontend.zip

cd /root/frontend-master

npm ci

npm run build

rm -rf /srv/www/webrx/*

mv /root/frontend-master/build/* /srv/www/webrx/

rm -rf /root/frontend-master
