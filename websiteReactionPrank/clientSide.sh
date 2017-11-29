#!/usr/bin/env bash
# Lots of information here:
# http://2016.padjo.org/tutorials/sqlite-your-browser-history/

sites=(facebook.com youtube.com)

function safariQuery() {
  sqlite3 ~/Library/Safari/History.db "
    SELECT visit_time, title, url
    FROM history_visits
    INNER JOIN history_items
      ON history_items.id = history_visits.history_item
    WHERE
      url like '%facebook.com%' OR
      url like '%youtube.com%'
   ORDER BY visit_time ASC;"
}

function chromeQuery() {
  sqlite3 "~/Library/Application Support/Google/Chrome/Default/History" "
    SELECT last_visit_time, title, url
    FROM urls
    ORDER BY last_visit_time ASC;"
}

function firefoxQuery(){
  historyFile=`find ~/Library/Application\ Support/Firefox/Profiles | grep "places.sqlite$"`;

  sqlite3 "$historyFile" "
    SELECT last_visit_date, url
    FROM moz_places
    ORDER BY last_visit_date ASC;"
}

