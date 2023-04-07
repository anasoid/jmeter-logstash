#!/bin/bash -e

SECONDS=0
STEP_TIME_CHECK=10
echo STEP_TIME_CHECK=$STEP_TIME_CHECK
echo CONF_EXEC_TIMEOUT=$CONF_EXEC_TIMEOUT
echo CONF_WAIT_FIRST_DATA=$CONF_WAIT_FIRST_DATA
echo CONF_WAIT_INACTIVITY=$CONF_WAIT_INACTIVITY

echo "Start Logstashs"


if [[ "$FILE_EXIT_AFTER_READ" != "true" || "$CONF_EXIT_AFTER_READ" != "true" ]]  ; then
    echo "Start in standalone mode"
    exec /usr/local/bin/docker-entrypoint "$@"
    
else
    
    echo "Start in parallel mode"
    exec /usr/local/bin/docker-entrypoint "$@" &
    
    echo "  Logstash Started"
    
    
    
    
    
    
    
    sleep 10
    echo CONF_EXEC_TIMEOUT=$CONF_EXEC_TIMEOUT
    echo STEP_TIME_CHECK=$STEP_TIME_CHECK
    echo CONF_WAIT_INACTIVITY=$CONF_WAIT_INACTIVITY
    echo CONF_READY_WAIT_FILE=$CONF_READY_WAIT_FILE
    echo CONF_EXIT_AFTER_READ=$EXIT_AFTER_READ
    
    STEP_TIME_CHECK=10
    ITERATIONS=$(($CONF_WAIT_FIRST_DATA / $STEP_TIME_CHECK))
    
    last_status="-1"
    
    DURATION=0
    #wait api available
    #check ready file
    if [  -z "$CONF_READY_WAIT_FILE" ]; then
        echo "Skip Ready wait"
    fi
    echo "Start Listener WAIT availble ($ITERATIONS)"
    for ((i = 0 ; i <= $ITERATIONS ; i++)); do
        #check ready file
        
        if [ -f "$CONF_READY_WAIT_FILE" ]; then
            echo " $(date) : Ready file found ($CONF_READY_WAIT_FILE)"
            break
        else
            echo " $(date) : Waiting Ready file ($CONF_READY_WAIT_FILE)"
        fi
        
        
        #Check logtash staus
        set +e
        status=$( curl -s 'localhost:9600/_node/stats/events' | grep -oP '"out":\K(\d+)')
        set -e
        echo "Logstash message out number: ($i)-> $status"
        if [[ "$status" == "0" || "$status" == "" ]]; then
            if  [[ "$DURATION" > "$CONF_WAIT_FIRST_DATA" ]]; then
                echo "Logstash exit waiting first data with  after $DURATION"
                break
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
    
fi


echo "Stop logstash"




