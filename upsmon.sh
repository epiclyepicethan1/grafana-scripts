#!/bin/bash
#takan from https://denlab.io/setup-a-wicked-grafana-dashboard-to-monitor-practically-anything/ and modified a bit
#Prepare to start the loop and warn the user
echo "Press [CTRL+C] to stop..."

    #Get the current dump of the stats
    upsstats=`pwrstat -status`
    
    #Lets try to find the lines we are looking for
    while read -r line; do
        #Check if we have the line we are looking for
        if [[ $line == *"State."* ]]
        then
          state=$line
        fi
        if [[ $line == *"Power Supply by"* ]]
        then
          supply=$line
        fi
        if [[ $line == *"Utility Voltage"* ]]
        then
          involts=$line
        fi
        if [[ $line == *"Output Voltage"* ]]
        then
          outvolts=$line
        fi
        if [[ $line == *"Battery Capacity"* ]]
        then
          capacity=$line
        fi
        if [[ $line == *"Remaining Runtime"* ]]
        then
          runtime=$line
        fi
        if [[ $line == *"Load."* ]]
        then
          load=$line
        fi
        if [[ $line == *"Line Interaction"* ]]
        then
          interaction=$line
        fi
    done <<< "$upsstats"
    
    #Remove the long string of .s
    state=$(echo $state | tr -s '[.]')
    supply=$(echo $supply | tr -s '[.]')
    involts=$(echo $involts | tr -s '[.]')
    outvolts=$(echo $outvolts | tr -s '[.]')
    capacity=$(echo $capacity | tr -s '[.]')
    runtime=$(echo $runtime | tr -s '[.]')
    load=$(echo $load | tr -s '[.]')
    interaction=$(echo $interaction | tr -s '[.]')
    
    #Lets parse out thevalues from the strings
    #First split on the .
    IFS='.' read -ra statearr <<< "$state"
    state=${statearr[1]}
    IFS='.' read -ra supplyarr <<< "$supply"
    supply=${supplyarr[1]}
    IFS='.' read -ra involtsarr <<< "$involts"
    involts=${involtsarr[1]}
    IFS='.' read -ra outvoltsarr <<< "$outvolts"
    outvolts=${outvoltsarr[1]}
    IFS='.' read -ra capacityarr <<< "$capacity"
    capacity=${capacityarr[1]}
    IFS='.' read -ra runtimearr <<< "$runtime"
    runtime=${runtimearr[1]}
    IFS='.' read -ra loadarr <<< "$load"
    load=${loadarr[1]}
    IFS='.' read -ra interactionarr <<< "$interaction"
    interaction=${interactionarr[1]}
    
    #We need an extra split for the load
    IFS='(' read -ra loadarr <<< "$load"
    loadwatt=${loadarr[0]}
    loadpercent=${loadarr[1]}
    
    #Remove unneeded spaces
    state=$(echo $state | xargs)
    supply=$(echo $supply | xargs)
    involts=$(echo $involts | xargs)
    outvolts=$(echo $outvolts | xargs)
    capacity=$(echo $capacity | xargs)
    runtime=$(echo $runtime | xargs)
    loadwatt=$(echo $loadwatt | xargs)
    loadpercent=$(echo $loadpercent | xargs)
    interaction=$(echo $interaction | xargs)
    
    #Now we just strip off some of the unneeded
    #info from the end of the strings
    involts=$(echo $involts | grep -o '[0-9]*')
    outvolts=$(echo $involts | grep -o '[0-9]*')
    runtime=$(echo $runtime | grep -o '[0-9]*')
    capacity=$(echo $capacity | grep -o '[0-9]*')
    loadwatt=$(echo $loadwatt | grep -o '[0-9]*')
    loadpercent=$(echo $loadpercent | grep -o '[0-9]*')
    
    echo "state: $state"
    echo "supply: $supply"
    echo "involts: $involts"
    echo "outvolts: $outvolts"
    echo "runtime: $runtime"
    echo "capacity: $capacity"
    echo "loadwatt: $loadwatt"
    echo "loadpercent: $loadpercent"
    echo "interaction: $interaction"
    
    #Finally we can write it to the database
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "ups_data,host=host1,sensor=battcharge value=$capacity"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "ups_data,host=host1,sensor=battload value=$loadpercent"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "ups_data,host=host1,sensor=battloadwatt value=$loadwatt"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "ups_data,host=host1,sensor=inputvoltage value=$involts"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "ups_data,host=host1,sensor=runtime value=$runtime"
   
