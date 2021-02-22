#!/bin/sh

cd /app/templates/skin/synio/locale/ru_RU/LC_MESSAGES
msgcat -n -F -o messages.po parts/*
msgfmt messages.po
npx po2json -f jed1.x messages.po messages.json
rm messages.po
