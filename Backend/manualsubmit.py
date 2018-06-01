import cv2
import numpy as np
from pathlib import Path
import os
import shutil
import database as db
import raidscan as rs

session = db.Session()

training_image_path = os.getcwd() + '/not_find_img'
p = Path(training_image_path)

url_image_path = os.getcwd() + '/url_img/'

print('***************************************************')
print('File name formating')
print('Submit Gym image the name format is')
print('    Fort_FortId.png. Example: Fort_110.png')
print('    Not valid fort image    : Fort_Not_xx.png')
print('Submit Pokemon image the name format is')
print('    Pokemon_PokemonId.png. Example: Pokemon_110.png')
print('***************************************************')

fort_count = 0
pokemon_count = 0

for fullpath_filename in p.glob('*.png'):
    filename = os.path.basename(fullpath_filename)
    print('Read', filename)
    image_name = filename.split('_')
    if image_name[0] == 'Fort':
        fort_id, ext = os.path.splitext(image_name[1])
        if fort_id.isdecimal()==True:
            print('fort_id:', fort_id)
            img = cv2.imread(str(fullpath_filename),3)
            gym_image_id = rs.get_gym_image_id(img)
            gym_image_fort_id = db.get_gym_image_fort_id(session, gym_image_id)
            if int(fort_id) == int(gym_image_fort_id):
                print('This gym image is already trained')
                os.remove(fullpath_filename)
            else:
                unknown_fort_id = db.get_unknown_fort_id(session)
                print('gym_images id:',gym_image_id,'fort_id:', gym_image_fort_id,'unknow_fort_id:',unknown_fort_id)
                if gym_image_fort_id == unknown_fort_id:
                    if db.update_gym_image(session,gym_image_id,fort_id) == True:
                        fort_result_file = os.getcwd() + '/success_img/Fort_' + str(fort_id) + '.png'
                        url_result_file = os.getcwd() + '/success_img/Fort_'+str(fort_id) + '_url.jpg'
                        url_org_file = os.getcwd() + '/url_img/'+str(fort_id) + '.jpg'
                        shutil.move(fullpath_filename, fort_result_file)
                        shutil.copy(url_org_file, fort_result_file)
                        fort_count = fort_count+1
                else:
                    print('The gym image is assigned as fort id:', gym_image_fort_id)
                    print('If the fort id is not correct, delete the gym image id:', gym_image_id)
                    print('and run submit.py again')
        elif str(fort_id) == 'Not':
            img = cv2.imread(str(fullpath_filename),3)
            gym_image_id = rs.get_gym_image_id(img)
            not_fort_id = db.get_not_a_fort_id(session)
            if db.update_gym_image(session,gym_image_id,not_fort_id) == True:
                fort_dest_file = os.getcwd() + '/not_valid_img/not_valid_' + str(gym_image_id) + '.png'
                shutil.move(fullpath_filename, fort_dest_file)
                print('gym image id:', gym_image_id, 'is set as not valid')
            
    elif image_name[0] == 'Pokemon':
        pokemon_id, ext = os.path.splitext(image_name[1])
        if pokemon_id.isdecimal()==True:
            print('pokemon_id:', pokemon_id)
            img = cv2.imread(str(fullpath_filename),3)
            pokemon_image_id = rs.get_pokemon_image_id(img)
            pokemon_image_pokemon_id = db.get_pokemon_image_pokemon_id(session, pokemon_image_id)
            if int(pokemon_id) == int(pokemon_image_pokemon_id):
                print('This pokemon image is already trained')
                os.remove(fullpath_filename)
            else:
                if int(pokemon_image_pokemon_id) == 0:
                    if db.update_pokemon_image(session,pokemon_image_id,pokemon_id)==True:
                        os.remove(fullpath_filename)
                        pokemon_count = pokemon_count +1
                else:
                    print('The pokemon image is assigned as pokemon id:', pokemon_image_pokemon_id)
                    print('If the pokemon id is not correct, delete the pokemon image id:', pokemon_image_id)
                    print('and run raidsubmit.py again')

print('Submitted')
print('  ',fort_count,'gym images')
print('  ',pokemon_count,'pokemon images')
                    
                    
                    
            
                
