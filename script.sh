#!/bin/bash

# https://spaceapi.io/
# https://directory.spaceapi.io/
jsonVersion="0.0.4"
FILE=status.json
TOPIC="cdl/status"
#QTTHOST=localhost.uucp
MQTTHOST=mozart.uucp
MQTTPORT=1883
# Lat, Lon
#LAT="40.18649730878143"
#LON="-74.06016247354387"
# 40.18652189759892, -74.06013028703497
#LAT="40.186373"
#LON="-74.060128"
LAT="40.18652189759892"
LON="-74.06013028703497"

cd ${HOME}/dev/git/compdecon.github.io/

sub () {
    topic="${1}"
    # Wait 3 seconds and return
    timeout 3 mosquitto_sub -C 1 -h "${MQTTHOST}" -p "${MQTTPORT}" -t "${topic}"
}

pub() {
    topic="${1}"
    msg="${2}"
    mosquitto_pub -h "${MQTTHOST}" -p "${MQTTPORT}" -q 0 -r -t "${topic}" -m "${msg}"
}

toKelvin() {
    #($1 − 32) × 5/9 + 273.15
    true
}

# Update the json
# push it to github

# What is dynamic
# location.timezone
# location.localtime
# lots of sensors (but not at this time)
#   0 = Front Gate
#     sensors.door_locks.[0].value = false
#   1 = Front Door
#     sensors.door_locks.[1].value = false
# Get weather forecast for KBLM
# curl https://api.weather.gov/gridpoints/PHI/83,90/forecast | jq '.properties.periods[0]'
# weather
#

# ------------------------------------------------------------------------------
# Problem: If I put this in a cronjob it will default to closed. So how do I run
#          a cron and have it correctly set the status.json?
# Answer:  ???
# ------------------------------------------------------------------------------
# getops
OPEN=0
#MSG="All visitors to the makerspace are required to mask as per the State of New Jersey requirements and maintain appropriate social distancing while in the building"
MSG="Sorry we're closed for the day."
# ------------------------------------------------------------------------------

###
### @FIXME: Some of these need to be cuaght if nothing returns or an expected value is not returned
###         See DOOR_LOCK and GATE_LOCK
MSG=$(sub "${TOPIC}/message")
PREMSG=$(sub "${TOPIC}/preUpdateMsg")
POSTMSG=$(sub "${TOPIC}/postUpdateMsg")
BLOGUPDATE=$(sub "${TOPIC}/blogUpdate")
STATE=$(sub "${TOPIC}/state")
DOOR_LOCK=$(sub "${TOPIC}/door_lock")
GATE_LOCK=$(sub "${TOPIC}/gate_lock")

# true or false but not quoted
if [ "X${STATE}" != "Xtrue" ]; then
    STATE=false
fi

if [ "X${DOOR_LOCK}" != "Xtrue" ]; then
    DOOR_LOCK=false
fi

if [ "X${GATE_LOCK}" != "Xtrue" ]; then
    GATE_LOCK=false
fi


# Occupancy
OLAB=0
OCLASS=0
OSTUDIO=0
OVSPACE=-1

# Humidity
HLAB="60.0"
HCLASS="60.0"
HSTUDIO="60.0"
HOUTSIDE="-1.0"

# Network Connections
CONNS=0

# Temperature
#UNIT="\u00b0C"
#UNIT="K"
TUNIT="\u00b0F"
TLAB=70
TCLASS=70
TSTUDIO=70
TOUTSIDE=$(jq '.temperature' /tmp/forecast || echo '-1')

#
# Probably need this to be in another cron that runs 4 times a day (every 6 hours)
#EATHER=$(curl -s https://api.weather.gov/gridpoints/PHI/83,90/forecast | jq '.properties.periods[0]')
WEATHER=$(cat /tmp/forecast)
if [ "x" == "x${WEATHER}" ]; then
    WEATHER="{}"
fi

SPACE=$(cat /tmp/nasa-alert.json)
if [ "x" == "x${SPACE}" ]; then
    SPACE="[]"
fi

# LOCATION
#       \"timezone\": \"$(date '+%Y/%m/%d %H:%M:%S %Z UTC%:z')\",
#                             Sun 27 Jun 2021 02:21:56 AM EDT
#       \"localtime\": \"$(date)\",
# state
#      \"lastchange\": $(date +%s),
#
# \"logo\": \"http://compdecon.org/wp-content/uploads/2018/10/cdl_white_large.png\",
JSON="{
  \"api_compatability\": [\"14\"],
  \"api\": \"0.13\",
  \"version\": \"${jsonVersion}\",
  \"comment\": \"API is a work in progress (${jsonVersion})\",
  \"space\": \"CDL - Computer Deconstruction Lab\",
  \"logo\": \"https://compdecon.github.io/images/CDL-Logo-black.png\",
  \"url\": \"https://compdecon.github.io/\",
  \"location\": {
      \"address\": \"Computer Deconstruction Lab, Building 9059, 2201 Marconi Road, Wall Township, N.J. 07719, USA\",
      \"lat\": ${LAT},
      \"lon\": ${LON},
      \"timezone\": \"America/New_York\",
      \"ext_time\": \"$(date '+%Y/%m/%d %H:%M:%S %Z UTC%:z')\",
      \"ext_localtime\": \"$(date)\",
      \"ext_tz\": \"$(date +%Z)\"
  },
  \"sensors\": {
      \"comment\": \"optional\",
      \"door_locked\": [
          {
              \"location\": \"Front gate\",
              \"value\": ${GATE_LOCK}
          }, {
              \"location\": \"Front door\",
              \"value\": ${DOOR_LOCK}
          }
      ],
      \"humidity\": [
          {
              \"location\": \"Lab\",
              \"unit\": \"%\",
              \"value\": ${HLAB}
          }, {
              \"location\": \"Studio\",
              \"unit\": \"%\",
              \"value\": ${HSTUDIO}
          }, {
              \"location\": \"Classroom\",
              \"unit\": \"%\",
              \"value\": ${HCLASS}
          }, {
              \"location\": \"Outside\",
              \"unit\": \"%\",
              \"value\": ${HOUTSIDE}
          }
      ],
      \"network_connections\": [
          {
              \"value\": ${CONNS}
          }
      ],
      \"occupancy\": [
          {
              \"location\": \"Lab\",
              \"value\": ${OLAB}
          }, {
              \"location\": \"Classroom\",
              \"value\": ${OCLASS}
          }, {
              \"location\": \"Studio\",
              \"value\": ${OSTUDIO}
          }, {
              \"location\": \"vspace\",
              \"value\": ${OVSPACE}
          }
      ],
      \"temperature\": [
          {
              \"location\": \"Lab\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TLAB}
          }, {
              \"location\": \"Classroom\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TCLASS}
          }, {
              \"location\": \"Studio\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TSTUDIO}
          }, {
              \"location\": \"Outside\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TOUTSIDE}
          }
      ]
  },
  \"ext_weather\": ${WEATHER},
  \"space_weather\": ${SPACE},
  \"contact\": {
    \"email\": \"info@compdecon.org\",
    \"phone\": \"+1-732-456-5001\",
    \"meetup\": \"https://www.meetup.com/compdecon/events/280930740\",
    \"irc\": \"\",
    \"ml\": \"cdl@groups.io\",
    \"identica\": \"\",
    \"twitter\": \"@compdecon\",
    \"facebook\": \"https://www.facebook.com/groups/compdecon\"
  },
  \"issue_report_channels\": [
    \"email\"
  ],
  \"feeds\": {
      \"blog\":{
          \"type\": \"application/rss+xml\",
          \"url\":\"http://compdecon.org/feed/\"
      }
  },
  \"links\": [
      {\"name\": \"SpaceAPI\", \"description\":\"spaceapi.io docs\",\"url\":\"https://spaceapi.io/docs/\"},
      {}
  ],
  \"state\": {
      \"open\": ${STATE},
      \"lastchange\": $(date +%s),
      \"message\": \"${MSG}.\",
      \"preMessage\": \"${PREMSG}.\",
      \"postMessage\": \"${POSTMSG}.\",
      \"blogUpdate\": \"${BLOGUPDATE}\",
      \"icon\": {
          \"open\": \"https://compdecon.github.io/images/open.png\",
          \"closed\": \"https://compdecon.github.io/images/closed.png\"
      },
      \"mqtt\": {
          \"host\": \"example.org\",
          \"closed\": \"closed\",
          \"tls\": true,
          \"topic\": \"compdecon/state\",
          \"port\": 1883,
          \"open\": \"open\"
    }
  },
  \"cam\": [
      \"https://example.org/cam\"
  ],
  \"events\": [
      {
          \"name\": \"Git push\",
          \"type\": \"git push\",
          \"timestamp\": 1624916770,
          \"extra\": \"ncherry@linuxha.com git pushed updates for the compdecon.github.io related code\"
      }
  ],
  \"projects\": [
  ],
  \"space\": \"CDL - Computer Deconstruction Lab\",
  \"spacefed\": {
      \"spacephone\": false,
      \"spacesaml\": false,
      \"spacenet\": false
  }
}"

# @FIXME: The events are static, that's not correct

###
### Take a backup of the old status.json
###
#cp status.json /tmp/status.json
egrep -v 'lastchange|timezone|localtime|ext_time' ${FILE} | jq '.' > /tmp/${FILE}

###
### Create a new status.json
###
#echo "${JSON}" > t-status.json
echo "${JSON}" | jq '.' > status.json
if [ ${PIPESTATUS[1]} != 0 ]; then
    echo -e "\n###\n### Bad json, bad, go to your room"'!'"\n###\n### compdecon.github.io not updated\n###"
    exit 1
fi

egrep -v 'lastchange|timezone|localtime|ext_time' ${FILE} | jq '.' > /tmp/t-${FILE}

###
### compare the two, if it has changed update
### Special handling: At midnight, update anyway so we're updated at least once a day
###
STR=$(date +%H:%S)
# crontab is currently:
# 10 * * * * bash -c ${HOME}/dev/git/compdecon.github.io/script.sh
if [ $STR == "00:10" ]; then
    true
else
    #diff status.json /tmp/status.json &>/dev/null
    diff /tmp/t-${FILE} /tmp/${FILE} &>/dev/null
fi

if [ $? -ne 0 ]; then
    ###
    ### ssh-agent stuff here
    ###

    ###
    ### Check for errors
    ###
    tfile=$(mktemp)
    source ~/tmp/dot.ssh-agent-njc.sh &>> ${tfile}
    #
    git add status.json &>> ${tfile}
    git commit -m "Automated status update" &>> ${tfile}
    git push  &>> ${tfile}
    rtn=$?
    if [ ${rtn} -ne 0 ]; then
        echo -e "Error: ${rtn}"
        cat ${tfile}
    fi
    rm ${tfile}
else
    echo 'No changes to report'
fi

exit 0

# -[ Fini ]---------------------------------------------------------------------

# These need retain
timeout 3 mosquitto_sub -C 1 -h "${MQTTHOST}" -p "${MQTTPORT}" -t "${topic}"
mosquitto_pub -h "${MQTTHOST}" -p "${MQTTPORT}" -q 0 -r -t "${topic}" -m "${msg}"

mosquitto_pub -q 0 -r -t "cdl/status/message" -m "Sorry we&#x27;re currently closed but we will be open next Monday at 7PM. Check us out on <a target=\"_blank\" title=\"Opens in a new tab\" href=\"https://www.facebook.com/groups/compdecon/\">Facebook</a>."
mosquitto_pub -r -t "cdl/status/preUpdateMsg" -m "InfoAge and all its museums including CDL will be closed December 25, 26, January 1, 2."
mosquitto_pub -r -t "cdl/status/postUpdateMsg" -m "This Monday, we'll be playing with Smart Home technology."

# Make the topic blank
mosquitto_pub -n -r -t "cdl/status/postUpdateMsg"

#
mosquitto_sub -C 1 -t "cdl/status/message"

# Using at to run a command later
$ at 23:55<enter>
at> mosquitto_pub -n -r -t "cdl/status/postUpdateMsg"
at> <^D>
$

mosquitto_pub -h "${MQTTHOST}" -p "${MQTTPORT}" -q 0 -r -t "cdl/status/preUpdateMsg" -m '<span style=\"background-color: gold; font-weight: bold\">&nbspFacemasks are required.&nbsp</span>'

###
### Test for msg skip
### If exists
###    remove msg skip
### else
###    run update
### fi
test -f /tmp/cdl-msg-skip && echo "rm -rf /tmp/cdl-msg-skip" || echo "run We're Open"
