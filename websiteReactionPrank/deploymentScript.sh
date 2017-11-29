#!/usr/bin/env bash
# Download and run a script from a prepspecified location.

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

###################################################################
 # Configuration variables
payloadURL="https://raw.githubusercontent.com/thiesgehrmann/arduinoPranks/master/websiteReactionPrank/scriptloc.txt"

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

function getPayloadURL(){
  local url="$1"
  curl -H 'Cache-Control: no-cache' -s "$url" \
   | grep -v -e '^#' -e'^$' \
   | head -n1
}

function downloadURL(){
  local url="$1"
  local outfile="$2"
  echo "Downloading $url"
  #wget -O "$2" "$1"
  #chmod +x "$2"
}

function downloadPayloadIfNeeded(){

  local remoteURL=`getPayloadURL "$payloadURL"`
  local remoteURLETag=`getURLETag "$remoteURL"`

  localURL=`head -n1 "$localPayloadURL"`
  localETag=`head -n1 "$localPayloadETag"`

  echo "$localURL -> $remoteURL"
  echo "$localETag -> $remoteURLETag"

    # We have a totally new URL, we should get it no matter what!
  if [ "$remoteURL" != "$localURL" ]; then
    echo "We have a new URL!"
    downloadURL "$remoteURL" "$localPayloadLoc"
    echo "$remoteURL" > "$localPayloadURL"
    echo "$remoteURLETag" > "$localPayloadETag"

  else
    echo "Same URL"

    if [ "$localETag" != "$remoteURLETag" ]; then
      echo "The payload has been updated!"
      downloadURL "$remoteURL" "$localPayloadLoc"
      echo "$remoteURLETag" > "$localPayloadETag"
    fi
  fi

}

function runPayload() {
  "$localPayloadLoc" &> /dev/null
}

###################################################################

echo "#################################"
echo "# Website Reaction Prank        #"
echo "#################################"

while [ true ]; do

  downloadPayloadIfNeeded

  runPayload

  sleep 15

done
