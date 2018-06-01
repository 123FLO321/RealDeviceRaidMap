import sys
import requests
import shutil
import database
import os

url_image_path = os.getcwd() + '/url_img/'

session = database.Session()

def download_img(url, file_name):
    try:
        r = requests.get(url, stream=True)
        if r.status_code == 200:
            with open(file_name, 'wb') as f:
                r.raw.decode_content = True
                shutil.copyfileobj(r.raw, f)
    except KeyboardInterrupt:
        print('Ctrl-C interrupted')
        session.close()
        sys.exit(1)
    except:
        print('Download error', url) 

def main():
    file_path = os.path.dirname(url_image_path)
    if not os.path.exists(file_path):
        os.makedirs(file_path)    
    for fort in database.get_forts(session):
        if fort.url is not None:
            filename = url_image_path + str(fort.id) + '.jpg'
            print('Downloading', filename)
            download_img(str(fort.url), str(filename))
    session.close()

if __name__ == '__main__':
    main()

