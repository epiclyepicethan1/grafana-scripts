import requests
import time
import json

data = dict(grant_type='PASSWORD', client_id='CLIENT_ID',
        client_secret='CLIENT_SECRET', username='USERNAME',
        password='PASSWORD', scope='read_station')

resp = requests.post('https://api.netatmo.com/oauth2/token', data=data)

if resp.status_code == 200:
     token = resp.json()
     token['expiry'] = int(time.time()) + token['expires_in']

resp = requests.get('https://api.netatmo.com/api/getstationsdata?access_token=' + token['access_token'])

if resp.status_code == 200:
    data = resp.json()

with open('data.json', 'w') as outfile:
json.dump(data, outfile)
