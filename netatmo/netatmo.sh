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
outdoor_temperature=$(awk "BEGIN {print $outdoor_temperature*1.8+32; exit}")
outdoor_min_temp=$(awk "BEGIN {print $outdoor_min_temp*1.8+32; exit}")
outdoor_max_temp=$(awk "BEGIN {print $outdoor_max_temp*1.8+32; exit}")

#write the data to the database

#write indoor data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_noise value=$indoor_noise"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_temperature value=$indoor_temperature"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_humidity value=$indoor_humidity"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_pressure value=$indoor_pressure"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_co2 value=$indoor_co2"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_absolutepressure value=$indoor_absolutepressure"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_min_temp value=$indoor_min_temp"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "indoor_data,host=weather,sensor=indoor_max_temp value=$indoor_max_temp"

#write outdoor data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=weather,sensor=outdoor_temperature value=$outdoor_temperature"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=weather,sensor=outdoor_humidity value=$outdoor_humidity"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=weather,sensor=outdoor_min_temp value=$outdoor_min_temp"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=weather,sensor=outdoor_max_temp value=$outdoor_max_temp"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "outdoor_data,host=weather,sensor=outdoor_battery_percent value=$outdoor_battery_percent"

#write wind data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=wind_max_wind_str value=$wind_max_wind_str"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=wind_windstrength value=$wind_windstrength"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=wind_gustangle value=$wind_gustangle"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=wind_max_wind_angle value=$wind_max_wind_angle"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=wind_windangle value=$wind_windangle"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=wind_battery_percent value=$wind_battery_percent"

#write rain data
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=rain_rain value=$rain_rain"
curl -i -XPOST 'http://INFLUXDB-IP:PORT/write?db=DATABASE-NAME' --data-binary "wind_data,host=weather,sensor=rain_battery_percent value=$rain_battery_percent"

#remove the data file
rm data.json
