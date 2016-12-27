#!/bin/bash
#taken from https://denlab.io/setup-a-wicked-grafana-dashboard-to-monitor-practically-anything/ and modified a bit
#Prepare to start the loop and warn the user
echo "Press [CTRL+C] to stop..."

    #Get the current dump of the stats
    transmissionstats=$(ssh user@192.168.1.108 "transmission-remote -n 'transmission:transmission' -st |  tail -n +9 | cut -c 3-")
    #extract the data we need
    started=$(echo $transmissionstats | grep -o -P '.{0,0}Started.{0,6}'| tr -d [:alpha:] | tr -d : | sed 's/ //g')
    uploaded=$(echo $transmissionstats | grep -o -P '.{0,0}Uploaded.{0,9}'|tr -d [:alpha:] | tr -d : | sed 's/ //g')
    downloaded=$(echo $transmissionstats | grep -o -P '.{0,0}Downloaded.{0,9}'|tr -d [:alpha:] | tr -d : | sed 's/ //g')
    ratio=$(echo $transmissionstats | grep -o -P '.{0,0}Ratio.{0,8}'|tr -d [:alpha:] | tr -d : | sed 's/ //g')
    duration=$(echo $transmissionstats | grep -o -P '.{0,0}Duration.{0,8}'|tr -d [:alpha:] | tr -d : | sed 's/ //g')

    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "transmission_data,host=host1,sensor=started value=$started"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "transmission_data,host=host1,sensor=uploaded value=$uploaded"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "transmission_data,host=host1,sensor=downloaded value=$downloaded"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "transmission_data,host=host1,sensor=ratio value=$ratio"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "transmission_data,host=host1,sensor=duration value=$duration"
