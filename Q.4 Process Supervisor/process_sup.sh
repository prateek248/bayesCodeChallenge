#!/bin/bash
wait_time_to_restart=$1
max_attempts=$2
proc_supvsd=$3
check_interval=$4
generate_log=$5
counter=0
attempt=("" "first" "second" "third" "fourth" "fifth")

initial_status=$(service $proc_supvsd status | grep "is running" | wc -l )
sleep $check_interval;
post_sleep_status=$(service $proc_supvsd status | grep "is running" | wc -l)

if [[ $initial_status -lt 1 ]] && [[ $post_sleep_status -lt 1 ]]; then
    while ( $post_sleep_status -lt 1)
    do
        sleep $wait_time_to_restart;
        if [[ $counter -gt 5 ]]; then
            echo "$(date) - Maximum attempts havce been made to restart the process $proc_supvsd. I'm giving up !!!" >> /var/log/heartbeat.log
            break
        else
            echo "$(date) - Service does not seems to be running. Attempting restart..." >> /var/log/heartbeat.log
            service $proc_supvsd restart
            counter=$(($counter+1))
            find_attempt=$(($counter+1))
            echo "$(date) - Service restarted ${attempt[$find_attempt]} time" >> /var/log/heartbeat.log
            post_sleep_status=$(service $proc_supvsd status | grep "is running" | wc -l)
        fi
    done
else
    echo "$(date) Done !!!" >> /var/log/heartbeat.log
fi