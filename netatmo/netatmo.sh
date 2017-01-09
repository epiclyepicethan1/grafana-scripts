#run the python script to retreive the data
python token.py

#separate the data out into the separate sections
indoor_data=$(jshon -e body -e devices < data.json | jq -r '.[].dashboard_data')
wind_data=$(jshon -e body -e devices < data.json | jq -r '.[].modules' |  jq -r '.[].dashboard_data' |  sed -e '1,75d')
outdoor_data=$(jshon -e body -e devices < data.json | jq -r '.[].modules' |  jq -r '.[].dashboard_data' | head -10)

#single out all the values for indoor
in_noise=$(echo $indoor_data | grep -o -P '.{0,0}Noise.{0,5}' | sed 's/[^0-9]*//g')
in_temperature=$(echo $indoor_data | grep -o -P '.{0,0}Temperature.{0,7}' | sed 's/[^0-9.-]*//g')
in_temp_trend=$(echo $indoor_data | jshon -e body -e devices < data.json | jq -r '.[].dashboard_data' | grep -o -P '.{0,0}temp_trend.{0,11}' |  grep -o 'down\|up\|stable')
in_humidity=$(echo $indoor_data |  grep -o -P '.{0,0}Humidity.{0,5}' | sed 's/[^0-9]*//g')
in_pressure=$(echo $indoor_data |  grep -o -P '.{0,0}"Pressure.{0,10}' | sed 's/[^0-9.]*//g')
in_CO2=$(echo $indoor_data | grep -o -P '.{0,0}CO2.{0,7}' | sed 's/[^0-9]*//g' | cut -c 2-)
in_min_temp=$(echo $indoor_data | grep -o -P '.{0,0}"min_temp.{0,7}' | sed 's/[^0-9.]*//g')
in_absolutepressure=$(echo $indoor_data |  grep -o -P '.{0,0}"AbsolutePressure.{0,9}' | sed 's/[^0-9.]*//g')
in_pressure_trend=$(echo $indoor_data |  grep -o -P '.{0,0}"pressure_trend.{0,11}' | grep -o 'down\|up\|stable')
in_max_temp=$(echo $indoor_data |  grep -o -P '.{0,0}"max_temp.{0,11}' | sed 's/[^0-9.]*//g')

#single out all the values for wind sensor
guststrength=$(echo $wind_data | grep -o -P '.{0,0}"GustStrength.{0,7}' | sed 's/[^0-9.]*//g')
max_wind_str=$(echo $wind_data | grep -o -P '.{0,0}"max_wind_str.{0,7}' | sed 's/[^0-9.]*//g')
windstrength=$(echo $wind_data | grep -o -P '.{0,0}"WindStrength.{0,7}' | sed 's/[^0-9.]*//g')
gustangle=$(echo $wind_data | grep -o -P '.{0,0}"GustAngle.{0,7}' | sed 's/[^0-9]*//g')
max_wind_angle=$(echo $wind_data | grep -o -P '.{0,0}"max_wind_angle.{0,11}' | sed 's/[^0-9]*//g')
windangle=$(echo $wind_data | grep -o -P '.{0,0}"WindAngle.{0,11}' | sed 's/[^0-9]*//g')

#single out all the values i want for outdoor
out_temperature=$(echo $outdoor_data | grep -o -P '.{0,0}"Temperature.{0,11}' | sed 's/[^0-9.-]*//g')
out_temp_trend=$(echo $outdoor_data | grep -o -P '.{0,0}"temp_trend.{0,11}' |  grep -o 'down\|up\|stable')
out_humidity=$(echo $outdoor_data |  grep -o -P '.{0,0}"Humidity.{0,11}' | sed 's/[^0-9.]*//g')
out_min_temp=$(echo $outdoor_data |  grep -o -P '.{0,0}"min_temp.{0,11}' | sed 's/[^0-9.]*//g')
out_max_temp=$(echo $outdoor_data | grep -o -P '.{0,0}"max_temp.{0,11}' | sed 's/[^0-9.]*//g')

#make celcius into farenheit
in_temperature=$(awk "BEGIN {print $in_temperature*1.8+32; exit}")
in_min_temp=$(awk "BEGIN {print $in_min_temp*1.8+32; exit}")
in_max_temp=$(awk "BEGIN {print $in_max_temp*1.8+32; exit}")

#make celcius into farenheit
out_temperature=$(awk "BEGIN {print $out_temperature*1.8+32; exit}")
out_min_temp=$(awk "BEGIN {print $out_min_temp*1.8+32; exit}")
out_max_temo=$(awk "BEGIN {print $out_max_temp*1.8+32; exit}")

#change the trends to numbers
if [[ $in_temp_trend == "down" ]]
then
  in_temp_trend=-1
fi
if [[ $in_temp_trend == "stable" ]]
then
  in_temp_trend=0
fi
if [[ $in_temp_trend == "up" ]]
then
  in_temp_trend=1
fi

if [[ $in_pressure_trend == "down" ]]
then
  in_pressure_trend=-1
fi
if [[ $in_pressure_trend == "stable" ]]
then
  in_pressure_trend=0
fi
if [[ $in_pressure_trend == "up" ]]
then
  in_pressure_trend=1
fi

if [[ $out_temp_trend == "down" ]]
then
  out_temp_trend=-1
fi
if [[ $out_temp_trend == "stable" ]]
then
  out_temp_trend=0
fi
if [[ $out_temp_trend == "up" ]]
then
  out_temp_trend=1
fi

#write the data to influxdb
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=noise value=$in_noise"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=temperature value=$in_temperature"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=temp_trend value=$in_temp_trend"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=humidity value=$in_humidity"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=pressure value=$in_pressure"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=CO2 value=$in_CO2"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=min_temp value=$in_min_temp"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=absolutepressure value=$in_absolutepressure"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=pressure_trend value=$in_pressure_trend"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "indoor_data,host=indoor,sensor=max_temp value=$in_max_temp"

curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "wind_data,host=wind,sensor=guststrength value=$guststrength"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "wind_data,host=wind,sensor=max_wind_str value=$max_wind_str"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "wind_data,host=wind,sensor=windstrength value=$windstrength"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "wind_data,host=wind,sensor=gustangle value=$gustangle"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "wind_data,host=wind,sensor=max_wind_angle value=$max_wind_angle"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "wind_data,host=wind,sensor=windangle value=$windangle"

curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "outdoor_data,host=outdoor,sensor=temperature value=$out_temperature"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "outdoor_data,host=outdoor,sensor=temp_trend value=$out_temp_trend"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "outdoor_data,host=outdoor,sensor=humidity value=$out_humidity"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "outdoor_data,host=outdoor,sensor=min_temp value=$out_min_temp"
curl -i -XPOST 'http://INFLUXDB_IP:PORT/write?db=database_name' --data-binary "outdoor_data,host=outdoor,sensor=max_temp value=$out_max_temp"

#remove the data file
rm data.json
