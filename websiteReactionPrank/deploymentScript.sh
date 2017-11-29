#!/usr/bin/sh
# Download and run a script from a prepspecified location.



scriptlocURL="https://raw.githubusercontent.com/thiesgehrmann/arduinoPranks/master/websiteReactionPrank/scriptloc.txt"

scriptURL=`curl "$scriptlocURL | grep -v -e '^#' -e'^$' | head -n1`
