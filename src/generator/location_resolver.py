import os
import sys
import json

import geojson
import requests
from shapely.geometry import shape

citynames = {
    "São Paulo": 1,
    "Rio de Janeiro": 2,
    "Cajamar": 3,
    "Queimados": 4,
    "Guarulhos": 5
}

MAPS_API_KEY = os.getenv("MAPS_API_KEY")
BASE_MAPS_URL = 'https://maps.googleapis.com/maps/api/geocode/json?latlng={lat},{long}&key=' + MAPS_API_KEY

with open(sys.argv[1]) as lf:
    locations = json.load(lf)['features']

for location in locations:
    print(
        f"Location | name: {location['properties'].get('name', 'NA')} "
        f"/ type: {location['properties'].get('type', 'NA')} "
        f"/ id: {location['properties'].get('id', 'NA')}")
    if location["geometry"]["type"] == 'LineString':
        for index, point in enumerate(location["geometry"]["coordinates"]):
            g1 = geojson.loads(json.dumps({
                "type": 'Point',
                "coordinates": point
            }))
            g2 = shape(g1)
            print(f"\t LineString point {index}: {g2.wkt}")

            req = requests.get(BASE_MAPS_URL.format(lat=point[1], long=point[0]))
            addresses = req.json()
            if len(addresses['results']) > 0:
                full_address = addresses['results'][0]['formatted_address']
                fist_address = full_address.split('-')[0].strip()
                neighborhood = full_address.split('-')[1].split(',')[0].strip()
                cityname = full_address.split(',')[2].split('-')[0].strip()
                city = citynames.get(cityname, cityname)
                zipcode = full_address.split(',')[-2].replace('-', '').strip()
                state = full_address.split(',')[-3].split('-')[1].strip()

                insert_statement = f"INSERT INTO location VALUES(DEFAULT, '{fist_address}', '', '{neighborhood}', " \
                                   f"'{zipcode}', {city}, '{state}', '{g2.wkt}', " \
                                   f"'Package {location['properties']['id']} - {index} step');"
                print(f"Possibly insert: {insert_statement}")
            else:
                print(f"\tFull response: {req.text}")

    else:
        g1 = geojson.loads(json.dumps(location["geometry"]))
        g2 = shape(g1)
        print(f"\tWKT: {g2.wkt}")
        req = requests.get(BASE_MAPS_URL.format(lat=location["geometry"]['coordinates'][1],
                                                long=location["geometry"]['coordinates'][0]))
        addresses = req.json()
        if len(addresses['results']) > 0:
            print(f"\tFormatted Location: {addresses['results'][0]['formatted_address']}")
        else:
            print(f"\tFull response: {req.text}")
    print("\n\n")
