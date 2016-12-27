#!/bin/bash
#taken from https://denlab.io/setup-a-wicked-grafana-dashboard-to-monitor-practically-anything/ and modified a bit
#This script gets the current memory and CPU usage for the
#main ESXi server.  It's hacky at best but it works.

#Prepare to start the loop and warn the user
echo "Press [CTRL+C] to stop..."

    #Let's start with the "easy" one, get the CPU usage
    cpu1=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.1 -Ov`
    cpu2=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.2 -Ov`
    cpu3=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.3 -Ov`
    cpu4=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.4 -Ov`
    cpu5=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.5 -Ov`
    cpu6=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.6 -Ov`
    cpu7=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.7 -Ov`
    cpu8=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.8 -Ov`
    cpu9=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.9 -Ov`
    cpu10=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.10 -Ov`
    cpu11=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.11 -Ov`
    cpu12=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrProcessorLoad.12 -Ov`
#   hdd0c=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrStorageSize.4 -Ov`
#   hdd1c=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrStorageSize.5 -Ov`
#   hdd2c=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrStorageSize.6 -Ov`
    hdd0u=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrStorageUsed.4 -Ov`
    hdd1u=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrStorageUsed.5 -Ov`
    hdd2u=`snmpget -v 2c -c public ESXI-IP HOST-RESOURCES-MIB::hrStorageUsed.6 -Ov`

    uptime=`snmpget -v 2c -c public ESXI-IP SNMPv2-MIB::sysUpTime.0 -Ov`

    #Strip out the value from the SNMP query
    cpu1=$(echo $cpu1 | cut -c 10-)
    cpu2=$(echo $cpu2 | cut -c 10-)
    cpu3=$(echo $cpu3 | cut -c 10-)
    cpu4=$(echo $cpu4 | cut -c 10-)
    cpu5=$(echo $cpu5 | cut -c 10-)
    cpu6=$(echo $cpu6 | cut -c 10-)
    cpu7=$(echo $cpu7 | cut -c 10-)
    cpu8=$(echo $cpu8 | cut -c 10-)
    cpu9=$(echo $cpu9 | cut -c 10-)
    cpu10=$(echo $cpu10 | cut -c 10-)
    cpu11=$(echo $cpu11 | cut -c 10-)
    cpu12=$(echo $cpu12 | cut -c 10-)
#   hdd0c=$(echo $hdd0c | cut -c 10-)
#   hdd1c=$(echo $hdd1c | cut -c 10-)
#   hdd2c=$(echo $hdd2c | cut -c 10-)
    hdd0u=$(echo $hdd0u | cut -c 10-)
    hdd1u=$(echo $hdd1u | cut -c 10-)
    hdd2u=$(echo $hdd2u | cut -c 10-)

    uptime=$(echo $uptime| cut -c 13- | cut -c -7)

    #Now lets get the hardware info from the remote host
    hwinfo=$(ssh root@ESXI-IP "esxcfg-info --hardware")


    #Lets try to find the lines we are looking for
    while read -r line; do
        #Check if we have the line we are looking for
        if [[ $line == *"Kernel Memory"* ]]
        then
          kmemline=$line
        fi
        if [[ $line == *"-Free."* ]]
        then
          freememline=$line
        fi
        #echo "... $line ..."
    done <<< "$hwinfo"

    #Remove the long string of .s
    kmemline=$(echo $kmemline | tr -s '[.]')
    freememline=$(echo $freememline | tr -s '[.]')

    #Lets parse out the memory values from the strings
    #First split on the only remaining . in the strings
    IFS='.' read -ra kmemarr <<< "$kmemline"
    kmem=${kmemarr[1]}
    IFS='.' read -ra freememarr <<< "$freememline"
    freemem=${freememarr[1]}
    #Now break it apart on the space
    IFS=' ' read -ra kmemarr <<< "$kmem"
    kmem=${kmemarr[0]}
    IFS=' ' read -ra freememarr <<< "$freemem"
    freemem=${freememarr[0]}

    #Now we can finally calculate used percentage
    used=$((kmem - freemem))
    used=$((used * 100))
    pcent=$((used / kmem))
    
    echo "CPU1: $cpu1%"
    echo "CPU2: $cpu2%"
    echo "CPU3: $cpu3%"
    echo "CPU4: $cpu4%"
    echo "CPU5: $cpu5%"
    echo "CPU6: $cpu6%"
    echo "CPU7: $cpu7%"
    echo "CPU8: $cpu8%"
    echo "CPU9: $cpu9%"
    echo "CPU10 $cpu10%"
    echo "CPU11: $cpu11%"
    echo "CPU12: $cpu12%"

    echo "HDD0U: $hdd0u%"
#   echo "HDD0C: $hdd0c%"
    echo "HDD1U: $hdd1u%"
#   echo "HDD1C: $hdd1c%"
    echo "HDD2U: $hdd2u%"
#   echo "HDD2C: $hdd2c%"


    echo "Memory Used: $pcent%"
    echo "$used"
    echo "$freemem"
    echo "$kmem"
    echo "Uptime: $uptime"
    
    #Write the data to the database
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=1 value=$cpu1"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=2 value=$cpu2"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=3 value=$cpu3"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=4 value=$cpu4"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=5 value=$cpu5"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=6 value=$cpu6"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=7 value=$cpu7"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=8 value=$cpu8"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=9 value=$cpu9"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=10 value=$cpu10"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=11 value=$cpu11"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=12 value=$cpu12"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=memory_usage value=$pcent"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=uptime value=$uptime"

#   curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=disk_capacity,disk_number=1 value=$hdd0c"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=disk_used,disk_number=1 value=$hdd0u"

#   curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=disk_capacity,disk_number=2 value=$hdd1c"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=disk_used,disk_number=2 value=$hdd1u"

#   curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=disk_capacity,disk_number=3 value=$hdd2c"
    curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "esxi_stats,host=esxi1,type=disk_used,disk_number=3 value=$hdd2u"

