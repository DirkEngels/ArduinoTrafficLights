#!/bin/sh
## The IP address of the device
IPADDR="192.168.1.99"

## The transfer cap, used as a more reliable threshold than for example a sleep
XFR_LIMIT="10k"


function clearLine()
{
    echo "\b\b\b\b\b\b\b\b\b\b\b\b\c"
}


while [ true ]
do

    # There is a better way to do this, but I'm not sure how to do this cross platform
    echo "     \b\b\b\b\bRed\c"
    curl --limit-rate ${XFR_LIMIT} http://${IPADDR}/?red=on\&yellow=off\&green=off 1&>/dev/null;
    clearLine

    echo "   \b\b\bYellow\c"
    curl --limit-rate ${XFR_LIMIT} http://${IPADDR}/?red=off\&yellow=on\&green=off 1&>/dev/null;
    clearLine

    echo "      \b\b\b\b\b\bGreen\c"
    curl --limit-rate ${XFR_LIMIT} http://${IPADDR}/?red=off\&yellow=off\&green=on 1&>/dev/null;
    clearLine

done


