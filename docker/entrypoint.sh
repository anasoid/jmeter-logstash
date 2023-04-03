#!/bin/bash -e

set -a pids

SECONDS=0
STEP_TIME_CHECK=10
echo STEP_TIME_CHECK=$STEP_TIME_CHECK
echo CONF_EXEC_TIMEOUT=$CONF_EXEC_TIMEOUT
echo CONF_WAIT_FIRST_DATA=$CONF_WAIT_FIRST_DATA
echo CONF_WAIT_INACTIVITY=$CONF_WAIT_INACTIVITY

echo "Start Logstashs"





if [[ -z $1 ]]  ; then
    exec /usr/local/bin/docker-entrypoint "$@" &
    mpid=$!  # Remember pid of child
else
    exec /usr/local/bin/docker-entrypoint &
    mpid=$!  # Remember pid of child
fi



echo "  Logstash Started"

#sleep 10
echo CONF_EXEC_TIMEOUT=$CONF_EXEC_TIMEOUT
echo STEP_TIME_CHECK=$STEP_TIME_CHECK
echo CONF_WAIT_INACTIVITY=$CONF_WAIT_INACTIVITY

STEP_TIME_CHECK=10
ITERATIONS=$(($CONF_WAIT_FIRST_DATA / $STEP_TIME_CHECK))

last_status="-1"

DURATION=0
#wait api available
echo "Start Listener WAIT availble ($ITERATIONS)"
for ((i = 0 ; i <= $ITERATIONS ; i++)); do
    set +e
    status=$( curl -s 'localhost:9600/_node/stats/events' | grep -oP '"out":\K(\d+)')
    set -e
    echo duration : $SECONDS
    echo "Logstash message out number: ($i)-> $status"
    if [[ "$status" == "0" || "$status" == "" ]]; then
        if  [[ "$DURATION" > "$CONF_WAIT_FIRST_DATA" ]]; then
            echo "Logstash exit waiting first data with  after $DURATION"
            exit 1;
        fi
        echo "Logstash ($i) waiting to start message ($status)..."
        sleep $STEP_TIME_CHECK
    else
        break
    fi
done

MAX_OCC=$(($CONF_WAIT_INACTIVITY / $STEP_TIME_CHECK))

# Wait data
ITERATIONS=$(($CONF_EXEC_TIMEOUT / $STEP_TIME_CHECK))
occ=0
for ((i = 0 ; i <= $ITERATIONS ; i++)); do
    set +e
    status=$( curl -s 'localhost:9600/_node/stats/events' | grep -oP '"out":\K(\d+)')
    set -e
    echo "Logstash message out number: $i($occ/$MAX_OCC)-> ($status)"
    
    
    if [ "$last_status" == "$status" ]; then
        echo "Logstash Detect inactivity number: $i($occ/$MAX_OCC)-> ($status)"
        occ=$((occ+1))
        if [ "$occ" -gt "$MAX_OCC" ]; then
            echo "Logstash finished on $i($occ/$MAX_OCC) with  ($status) messages"
            break;
        fi
        sleep $STEP_TIME_CHECK
    else
        last_status=$status
        occ=0
        echo "Logstash ($i iterations) waiting to finish all message $status ..."
        sleep $STEP_TIME_CHECK
    fi
    
done

echo "Stop logstash"




