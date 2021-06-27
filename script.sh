#!/bin/bash

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
MSG="All visitors to the makerspace are required to mask as per the State of New Jersey requirements and maintain appropriate social distancing while in the building"
MSG="Experimenting with SpaceAPI"

set -x
while getopts "c:hm:x:" opt; do
    case "${opt}" in
        c) # CDL (Podcast Studio)
            if [ $OPTARG -eq 1 ]; then
                OPEN=1
            else
                OPEN=
            fi
            # 1 = open
            # 0 = closed
            ;;

        x) # IXR (Makerspace)
            if [ $OPTARG -eq 1 ]; then
                OPEN=1
            else
                OPEN=
            fi
            # 1 = open
            # 0 = closed
            ;;

        h) # process option h
            # 1 = open
            # 0 = closed
            ;;

        m) # process option t
            MSG="$OPTARG"
            # 1 = open
            # 0 = closed
            ;;

        \?)
           echo $@
           echo $opt
           echo $OPTARG
           echo $OPTIND
           echo $OPTERR
           echo "Usage: cmd [-c n] [-x n] [-m \"msg\"]"
           exit 1
           ;;
    esac
done
set +x

shift $((OPTIND - 1))
#shift $(expr $OPTIND - 1 )

# ------------------------------------------------------------------------------

if [ "${OPEN}" == "1" ]; then
    # 
    STATE="open"
    LSTATE="true"
    DOOR_LOCK="true"
    GATE_LOCK="true"
    # Occupancy
    OLAB=1
    OCLASS=0
    OSTUDIO=0
    OVSPACE=-1
else
    # 
    STATE="closed"
    LSTATE="false"
    DOOR_LOCK="false"
    GATE_LOCK="false"
    # Occupancy
    OLAB=0
    OCLASS=0
    OSTUDIO=0
    OVSPACE=-1
fi

# Humidity
HLAB="60.0"
HCLASS="60.0"
HSTUDIO="60.0"
HOUTSIDE="-1.0"

# Network Connections
CONNS=0

# Temperature
#UNIT="\u00b0C"
TUNIT="\u00b0F"
#UNIT="\u00b0K"
TLAB=70
TCLASS=70
TSTUDIO=70
TOUTSIDE=-1

#
# Probably need this to be in another cron that runs 4 times a day (every 6 hours)
#EATHER=$(curl -s https://api.weather.gov/gridpoints/PHI/83,90/forecast | jq '.properties.periods[0]')
WEATHER=$(cat /tmp/forecast)
# LOCATION
#       \"timezone\": \"$(date '+%Y/%m/%d %H:%M:%S %Z UTC%:z')\",
#                             Sun 27 Jun 2021 02:21:56 AM EDT
#       \"localtime\": \"$(date)\",
# state
#      \"lastchange\": $(date +%s),
#
JSON="{
  \"api_compatability\": [\"14\"],
  \"api\": \"0.13\",
  \"version\": \"0.0.1 alpha\",
  \"comment\": \"API is a work in progress\",
  \"space\": \"CDL - Computer Deconstruction Lab\",
  \"logo\": \"http://compdecon.org/wp-content/uploads/2018/10/cdl_white_large.png\",
  \"logo\": \"https://compdecon.github.io/images/CDL-Logo-black.png\",
  \"url\": \"https://compdecon.github.io/\",
  \"location\": {
      \"address\": \"Computer Deconstruction Lab, Building 9059, 2201 Marconi Road, Wall Township, N.J. 07719, USA\",
      \"lat\": -74.06020538859792,
      \"long\": 40.186497308776936,
      \"timezone\": \"$(date '+%Y/%m/%d %H:%M:%S %Z UTC%:z')\",
      \"localtime\": \"$(date)\",
      \"comment\": \"date '+%Y/%m/%d %H:%M:%S %Z UTC%:z'# EDT/GMT+4 EST/GMT+5\"
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
  \"weather\": ${WEATHER},
  \"contact\": {
    \"email\": \"info@compdecon.org\",
    \"phone\": \"+1-732-456-5001\",
    \"meetup\": \"\",
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
      \"open\": ${LSTATE},
      \"lastchange\": $(date +%s),
      \"message\": \"${MSG}.\",
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
  ],
  \"events\": [
      {
          \"name\": \"N/A\",
          \"type\": \"\",
          \"timestamp\": -1,
          \"extra\": \"\"
      }, {
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

###
### Take a backup of the old status.json
###
cp status.json /tmp/status.json
###
### Create a new status.json
###
echo ${JSON} > status.json

###
### compare the two, if it has changed update
### Special handling: At midnight, update anyway so we're updated at least once a day
###
STR=$(date +%H)
if [ $STR == "00" ]; then
    true
else
    diff status.json /tmp/status.json &>/dev/null
fi
if [ $? -ne 0 ]; then
    ###
    ### ssh-agent stuff here
    ###
    source ~/tmp/dot.ssh-agent-njc.sh
    #
    git add status.json
    git commit -m "Automated status update"
    ###
    ### Should check for errors
    ###
    git push
fi

exit 0

# -[ Fini ]---------------------------------------------------------------------

# Now we need to be sure that the ssh-agent is runnint or start our own

# Totally rewrote this so now it should only run once
# unless someone manually ran ssh-agent
#
# When done there should be one ssh-agent running for this user
# there should be a ~/tmp/dot.ssh-agent-${LOGNAME}.sh with the correct permissions
#
# Notes:
# https://www.freshblurbs.com/blog/2013/06/22/github-multiple-ssh-keys.html#tldr
mkdir -p ~/tmp
# Process check (see if it's already running)
xPROC=ssh-agent
File="${HOME}/tmp/dot.ssh-agent-${LOGNAME}.sh"
# Get the count
CNT=$(ps aux | grep ${LOGNAME} | grep -v grep | grep ${xPROC}\$ | wc -l)

case $CNT in
    0)
        # None are already running
        # run it for the first time
        ssh-agent | tee ${File}

        if [ ! -f ${File} ]; then
            echo "Error creating ${File}"
            exit 1
        else
            chmod +x ${File}
            . ${File}
            # Add the needed keys
            ssh-add ~/.ssh/id_rsa-linuxha
            ssh-add -L
        fi

        exit 0
        ;;
    1)
        # It's already running
        # get the information for the running script
        xPID=$(ps aux | grep ${LOGNAME} | grep -v grep | grep ${xPROC}\$ | awk '{print $2}')

        # Hmm, tell the user to source this:
        if [ -x ${File} ]; then
            grep -q "SSH_AGENT_PID=${xPID};" ${File}
            if [ $? -eq 0 ]; then
                echo "Please source ${File}"
                cat ${File}
                exit 1
            fi

            echo "SSH_AGENT_PID mismatch, creating new source file"
            echo -e "${LOGNAME}'s ${xPROC} found with PID = ${xPID}"
            echo -n "Source file has: " ; grep "SSH_AGENT_PID=" ${File}
            mv ${File} ${File}.err
            
            xSOCK=$(netstat -nap 2>/dev/null | grep agent | grep '/tmp/ssh-' | awk '{print $10}')
            (echo "SSH_AUTH_SOCK=${xSOCK};"
            echo "export SSH_AUTH_SOCK;"
            echo "SSH_AGENT_PID=${xPID};"
            echo "export SSH_AGENT_PID;"
            echo "echo Agent pid ${xPID}") | tee ${File}
            chmod +x ${File}
        else
            echo -e "${LOGNAME}'s ${xPROC} found with PID = ${xPID}\n"
            echo "but source file doesn't exist"
            
            xSOCK=$(netstat -nap 2>/dev/null | grep agent | grep '/tmp/ssh-' | awk '{print $10}')
            (echo "SSH_AUTH_SOCK=${xSOCK};"
            echo "export SSH_AUTH_SOCK;"
            echo "SSH_AGENT_PID=${xPID};"
            echo "export SSH_AGENT_PID;"
            echo "Agent pid ${xPID}") | tee ${File}
            chmod +x ${File}
        fi
        echo -e "\nPlease source ${File}"
        exit 1
        ;;
    *)
        # Uhm, I'm confused
        # Probably more than one running
        # Let the user know
        echo "Error, more than one ${xPROC} is running"
        ps aux | grep ${LOGNAME} | grep -v grep | grep ${xPROC}\$

        cat ${File}
        
        exit 2
        ;;
esac

################################################################################
# Sample  ~/tmp/dot.ssh-agent-njc.sh
#SSH_AUTH_SOCK=/tmp/ssh-8OJ63T67tTkR/agent.10216; export SSH_AUTH_SOCK;
#SSH_AGENT_PID=10218; export SSH_AGENT_PID;
#echo Agent pid 10218;

# linuxha ssh keys are fine
# then we can
# git add status.json ; git commit -m "status.json update" ; git push
