#run the python script to retreive the data
python token.py

#parse indoor data
indoor_noise=$(jshon -e body -e devices -e 0 -e dashboard_data -e Noise < data.json)
indoor_temperature=$(jshon -e body -e devices -e 0 -e dashboard_data -e Temperature < data.json)
indoor_humidity=$(jshon -e body -e devices -e 0 -e dashboard_data -e Humidity < data.json)
indoor_pressure=$(jshon -e body -e devices -e 0 -e dashboard_data -e Pressure < data.json)
indoor_co2=$(jshon -e body -e devices -e 0 -e dashboard_data -e CO2 < data.json)
indoor_absolutepressure=$(jshon -e body -e devices -e 0 -e dashboard_data -e AbsolutePressure < data.json)
indoor_min_temp=$(jshon -e body -e devices -e 0 -e dashboard_data -e min_temp < data.json)
indoor_max_temp=$(jshon -e body -e devices -e 0 -e dashboard_data -e max_temp < data.json)

#parse outdoor data
outdoor_temperature=$(jshon -e body -e devices -e 0 -e modules -e 0 -e dashboard_data -e Temperature< data.json)
outdoor_humidity=$(jshon -e body -e devices -e 0 -e modules -e 0 -e dashboard_data -e Humidity < data.json)
outdoor_min_temp=$(jshon -e body -e devices -e 0 -e modules -e 0 -e dashboard_data -e min_temp < data.json)
outdoor_max_temp=$(jshon -e body -e devices -e 0 -e modules -e 0 -e dashboard_data -e max_temp < data.json)
outdoor_battery_percent=$(jshon -e body -e devices -e 0 -e modules -e 0 -e battery_percent < data.json)

#parse wind data
wind_guststrength=$(jshon -e body -e devices -e 0 -e modules -e 1 -e dashboard_data -e GustStrength < data.json)
wind_max_wind_str=$(jshon -e body -e devices -e 0 -e modules -e 1 -e dashboard_data -e max_wind_str < data.json)
wind_windstrength=$(jshon -e body -e devices -e 0 -e modules -e 1 -e dashboard_data -e WindStrength < data.json)
wind_gustangle=$(jshon -e body -e devices -e 0 -e modules -e 1 -e dashboard_data -e GustAngle < data.json)
wind_max_wind_angle=$(jshon -e body -e devices -e 0 -e modules -e 1 -e dashboard_data -e max_wind_angle < data.json)
wind_windangle=$(jshon -e body -e devices -e 0 -e modules -e 1 -e dashboard_data -e WindAngle < data.json)
wind_battery_percent=$(jshon -e body -e devices -e 0 -e modules -e 1 -e battery_percent < data.json)

#parse rain data
rain_rain=$(jshon -e body -e devices -e 0 -e modules -e 2 -e dashboard_data -e Rain < data.json)
rain_battery_percent=$(jshon -e body -e devices -e 0 -e modules -e 2 -e battery_percent < data.json)

#convert celcius to farenheit
indoor_temperature=$(awk "BEGIN {print $indoor_temperature*1.8+32; exit}")
indoor_min_temp=$(awk "BEGIN {print $indoor_min_temp*1.8+32; exit}")
indoor_max_temp=$(awk "BEGIN {print $indoor_max_temp*1.8+32; exit}")

#write the data to the database

#write indoor data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_noise"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_temperature"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_humidity"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_pressure"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_co2"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_absolutepressure"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_min_temp"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=indoor,sensor=indoor value=$indoor_max_temp"

#write outdoor data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=indoor,sensor=outdoor value=$outdoor_temperature"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=indoor,sensor=outdoor value=$outdoor_humidity"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=indoor,sensor=outdoor value=$outdoor_min_temp"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=indoor,sensor=outdoor value=$outdoor_max_temp"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=indoor,sensor=outdoor value=$outdoor_battery_percent"

#write wind data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=wind value=$wind_max_wind_str"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=wind value=$wind_windstrength"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=wind value=$wind_gustangle"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=wind value=$wind_max_wind_angle"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=wind value=$wind_windangle"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=wind value=$wind_battery_percent"

#write rain data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=rain value=$rain_rain"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=indoor,sensor=rain value=$rain_battery_percent"

#remove the data file
rm data.json
