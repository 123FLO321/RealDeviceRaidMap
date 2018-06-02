import sys
import cv2
import numpy as np
from pathlib import Path
import os
import shutil
import matching as mt
import database as db
import raidscan as rs
import time

unknown_image_path = os.getcwd() + '/unknown_img'
url_image_path = os.getcwd() + '/url_img'

success_img_path = os.getcwd() + '/success_img/'
need_check_img_path = os.getcwd() + '/need_check_img/'
not_find_img_pth = os.getcwd() + '/not_find_img/'

def findfort_main():
    # Check directories 
    file_path = os.path.dirname(unknown_image_path+'/')
    if not os.path.exists(file_path):
        print('Cannot find unknow_img directory. Run raidscan.py to create the directory')    
        return

    file_path = os.path.dirname(url_image_path+'/')
    if not os.path.exists(file_path):
        print('Cannot find url_img directory. Run downloadfortimg.py')
        print('to create the directory and download fort images')
        return

    # Create directories if not exists
    file_path = os.path.dirname(success_img_path)
    if not os.path.exists(file_path):
        os.makedirs(file_path)
    file_path = os.path.dirname(need_check_img_path)
    if not os.path.exists(file_path):
        os.makedirs(file_path)
    file_path = os.path.dirname(not_find_img_pth)
    if not os.path.exists(file_path):
        os.makedirs(file_path)
    
    p = Path(unknown_image_path)
    p_url = Path(url_image_path)

    while True:
        print('Run find fort task')
        session = db.Session()
        max_value = 0.0
        max_fort_id = 0
        max_url_fullpath_filename = ''
        new_img_count = 0
        for fort_fullpath_filename in p.glob('GymImage*.png'):
            new_img_count = new_img_count+1
            fort_filename = os.path.basename(fort_fullpath_filename)
            max_fort_id = 0
            max_value = 0.0 
            for url_fullpath_filename in p_url.glob('*.jpg'):
                try:
                    result = mt.fort_image_matching(str(url_fullpath_filename), str(fort_fullpath_filename))
                    url_filename = os.path.basename(url_fullpath_filename)
                    fort_id, ext = os.path.splitext(url_filename)            
        #            print('fort_id:',fort_id,'result:',result,'max_value:',max_value, 'max_fort_id:', max_fort_id)
                    if result >= max_value:
                        max_value = result
                        max_fort_id = fort_id
                        max_url_fullpath_filename = url_fullpath_filename
                except:
                    print('Matching error')
            print('fort_filename:',fort_filename, 'max_fort_id:',max_fort_id,'max_value:', max_value)
            if float(max_value) >= 0.90:
                img = cv2.imread(str(fort_fullpath_filename),3)
                gym_image_id = rs.get_gym_image_id(img)
                gym_image_fort_id = db.get_gym_image_fort_id(session, gym_image_id)
                if int(max_fort_id) == int(gym_image_fort_id):
                    print('This gym image is already trained')
                else:
                    unknown_fort_id = db.get_unknown_fort_id(session)
                    print('gym_images id:',gym_image_id,'fort_id:', gym_image_fort_id,'unknow_fort_id:',unknown_fort_id)
                    if gym_image_fort_id == unknown_fort_id:
                        db.update_gym_image(session,gym_image_id,max_fort_id)
                    else:
                        print('The gym image is assigned as fort id:', gym_image_fort_id)
                        print('If the fort id is not correct, delete the gym image id:', gym_image_id)
                        print('and run submit.py again')       
                fort_result_file = os.getcwd() + '/success_img/Fort_' + str(max_fort_id) + '.png'
                url_result_file = os.getcwd() + '/success_img/Fort_'+str(max_fort_id) + '_url.jpg'
                shutil.move(fort_fullpath_filename, fort_result_file)
                shutil.copy(max_url_fullpath_filename, url_result_file)
                print('Successfully found fort id:', max_fort_id)
            elif float(max_value) >= 0.85:
                fort_result_file = os.getcwd() + '/need_check_img/Fort_' + str(max_fort_id) + '.png'
                url_result_file = os.getcwd() + '/need_check_img/Fort_'+str(max_fort_id) + '_url.jpg'
                shutil.move(fort_fullpath_filename, fort_result_file)
                shutil.copy(max_url_fullpath_filename, url_result_file)
                print('Found fort id:', max_fort_id, ', but need to verify')
            else:
                fort_result_file = os.getcwd() + '/not_find_img/' + str(fort_filename)
                url_result_file = os.getcwd() + '/not_find_img/'+str(max_fort_id) + '.jpg'
                shutil.move(fort_fullpath_filename, fort_result_file)
                shutil.copy(max_url_fullpath_filename, url_result_file)
                print('Can not find fort:', max_fort_id, ', check the image in not_find_img')

        print(new_img_count, 'new fort image processed')
        session.close()
        time.sleep(30) # task runs every 10 seconds

    print('Done')
    return
    
if __name__ == '__main__':
    findfort_main()

                    
                    
                    
            
                
