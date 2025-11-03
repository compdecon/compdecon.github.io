#!/bin/bash

###
### cron eats 2 backslashes when passing from cron to bash, 2 more are needed for
### getopts below. So 5 '\'s are needed in cron to crrectly escape things like double
### qoutes
###
echo "<$*>" >/tmp/updateCDL.log

FILE=status.json
TOPIC="cdl/status"
#QTTHOST=localhost.uucp
MQTTHOST=mozart.uucp
MQTTPORT=1883

sub () {
    topic="${1}"
    # Wait 3 seconds and return
    timeout 3 mosquitto_sub -C 1 -h "${MQTTHOST}" -p "${MQTTPORT}" -t "${topic}"
}

pub() {
    topic="${1}"
    msg="${2}"
    echo "MSG [$2]" >>/tmp/updateCDL.log
    mosquitto_pub -h "${MQTTHOST}" -p "${MQTTPORT}" -q 1 -r -t "${topic}" -m "${msg}"
}

help() {
    echo "Usage: cmd [-c n] [-x n] [-m \"msg\"]"
    echo "       keep -m  \"msg\" last"
    exit 1
}

if [ $# -eq 0 ]; then
    help
fi

while getopts "c:hm:x:" opt; do
    case "${opt}" in
        c) # CDL (Podcast Studio)
            if [ $OPTARG -eq 1 ]; then
                # Pub open
                pub "${TOPIC}/state" "true"
                pub "${TOPIC}/door_lock" "true"
                pub "${TOPIC}/gate_lock" "true"
            else
                pub "${TOPIC}/state" "false"
                pub "${TOPIC}/door_lock" "false"
                pub "${TOPIC}/gate_lock" "false"
                pub "${TOPIC}/message" "Experimenting with SpaceAPI and my scripts"
            fi
            # 1 = open
            # 0 = closed
            ;;

        x) # IXR (Makerspace)
            if [ $OPTARG -eq 1 ]; then
                # Pub open
                pub "${TOPIC}/state" "true"
                pub "${TOPIC}/door_lock" "true"
                pub "${TOPIC}/gate_lock" "true"
            else
                pub "${TOPIC}/state" "false"
                pub "${TOPIC}/door_lock" "false"
                pub "${TOPIC}/gate_lock" "false"
                pub "${TOPIC}/message" "Experimenting with SpaceAPIand my scripts"
            fi
            # 1 = open
            # 0 = closed
            ;;
 
        m) # process option t
            echo "OPTARG [${OPTARG}]" >>/tmp/updateCDL.log
            pub "${TOPIC}/message" "${OPTARG}"
            # 1 = open
            # 0 = closed
            ;;

        h) # process option h
            help
            ;;
        \?)
            help
            ;;
    esac
done

shift $((OPTIND - 1))
#shift $(expr $OPTIND - 1 )

###
### Update the status.json
###
${HOME}/dev/git/compdecon.github.io/script.sh

# sed 's/<[^>]*>//g ; /^$/d'
