import sys
import requests
import shutil
import database
import os
import time
from config import MAP_START, MAP_END

url_image_path = os.getcwd() + '/url_img/'

session = database.Session()

def download_img(url, file_name):
    retry = 1
    while retry <= 5:
        try:
            r = requests.get(url, stream=True, timeout=5)
            if r.status_code == 200:
                with open(file_name, 'wb') as f:
                    r.raw.decode_content = True
                    shutil.copyfileobj(r.raw, f)
                break
        except KeyboardInterrupt:
            print('Ctrl-C interrupted')
            session.close()
            sys.exit(1)
        except:
            retry=retry+1
            print('Download error', url)
            if retry <= 5:
                print('retry:', retry)
            else:
                print('Failed to download after 5 retry')

def main():
    check_boundary = True
    if (MAP_START[0] == 0 and MAP_START[1] == 0) or (MAP_END[0] == 0 and MAP_END[1] == 0):
        check_boundary = False
    else:
        north = max(MAP_START[0], MAP_END[0])
        south = min(MAP_START[0], MAP_END[0])
        east = max(MAP_START[1], MAP_END[1])
        west = min(MAP_START[1], MAP_END[1])
        
    file_path = os.path.dirname(url_image_path)
    if not os.path.exists(file_path):
        os.makedirs(file_path)    
    for fort in database.get_forts(session):
        if fort.url is not None:
            in_boundary = True
            if check_boundary == True:
                lat_check = (fort.lat-north)*(fort.lat-south)
                lon_check = (fort.lon-east)*(fort.lon-west)
#                print(lat_check, lon_check)
                if lat_check<=0.0 and lon_check<=0.0:
                    in_boundary = True
                else:
                    in_boundary = False
            if in_boundary == True:
                filename = url_image_path + str(fort.id) + '.jpg'
                print('Downloading', filename)
                download_img(str(fort.url), str(filename))
#                time.sleep(0.2)
    session.close()

if __name__ == '__main__':
    main()

