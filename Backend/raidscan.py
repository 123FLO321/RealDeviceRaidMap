import sys
import cv2
import numpy as np
from pathlib import Path
import os
import time
import math
import shutil
from PIL import Image
import pytesseract
import datetime
from logging import basicConfig, getLogger, FileHandler, StreamHandler, DEBUG, INFO, ERROR, Formatter
import time
import database

log_fmt='%(asctime)s [%(filename)-12.12s] [%(levelname)-5.5s]  %(message)s'
logFormatter = Formatter(log_fmt)
logpath = os.getcwd()+'/raidscan.log'
basicConfig(filename=logpath, format=log_fmt, level=DEBUG)

LOG = getLogger('')
console=StreamHandler();
console.setLevel(DEBUG)
console.setFormatter(logFormatter)
LOG.addHandler(console)

process_img_path = os.getcwd() + '/process_img/'
copy_path = os.getcwd() + '/unknown_img/'
not_find_path = os.getcwd() + '/not_find_img/'

# Create directories if not exists
file_path = os.path.dirname(process_img_path)
if not os.path.exists(file_path):
    LOG.info('process_img directory created')
    os.makedirs(file_path)

file_path = os.path.dirname(copy_path)
if not os.path.exists(file_path):
    LOG.info('unknown_img directory created')
    os.makedirs(file_path)

file_path = os.path.dirname(not_find_path)
if not os.path.exists(file_path):
    LOG.info('not_find_img directory created')
    os.makedirs(file_path)

p = Path(process_img_path)

timefile = "time.png"
level1_num = 328950.0

session = database.Session()

gym_db = [gym for gym in database.get_gym_images(session)]
LOG.info('{} gym images loaded'.format(len(gym_db)))
#for gym in gym_db:
#    LOG.debug('%d %d %d %d %d %d %d %d', gym.id, gym.fort_id, gym.param_1, gym.param_2, gym.param_3, gym.param_4, gym.param_5, gym.param_6)

mon_db = [mon for mon in database.get_pokemon_images(session)]
LOG.info('{} pokemon images loaded'.format(len(mon_db)))

unknown_fort_id = database.get_unknown_fort_id(session)
not_a_fort_id = database.get_not_a_fort_id(session)

# Detect level of raid from level image
def detectLevel(level_img):
    img_gray = cv2.cvtColor(level_img,cv2.COLOR_BGR2GRAY)
    ret,thresh1 = cv2.threshold(img_gray,240,255,cv2.THRESH_BINARY_INV)
    height, width, channel = level_img.shape
    scale = width/320
    level = int(cv2.sumElems(thresh1)[0]/(level1_num*scale*scale) + 0.2)
#    cv2.imshow('level', thresh1)
#    cv2.waitKey(0)
    return level

# Detect hatch time from time image
def detectTime(time_img):
    img_gray = cv2.cvtColor(time_img,cv2.COLOR_BGR2GRAY)
    ret,thresh1 = cv2.threshold(img_gray,240,255,cv2.THRESH_BINARY_INV)
    cv2.imwrite(timefile, thresh1)
    text = pytesseract.image_to_string(Image.open(timefile))
    os.remove(timefile)
#    cv2.imshow('time', thresh1)
#    cv2.waitKey(0)
    return text

# Detect gym from raid sighting image
def detectGym(raid_img):
    global gym_db
    
    height, width, channels = raid_img.shape
    
    org_top_y = 40
    org_top_h = 30
    org_top_x = 135
    org_top_w = 50
    org_left_y = 125
    org_left_h = 70
    org_left_x = 45
    org_left_w = 25
    
    scale = width/320
    LOG.info('scale: {}'.format(scale))

    top_y = int(org_top_y*scale)
    top_h = int(org_top_h*scale)
    top_x = int(org_top_x*scale)
    top_w = int(org_top_w*scale)
    left_y = int(org_left_y*scale)
    left_h = int(org_left_h*scale)
    left_x = int(org_left_x*scale)
    left_w = int(org_left_w*scale)
    
    cropTop = raid_img[top_y:top_y+top_h, top_x:top_x+top_w]
    cropLeft = raid_img[left_y:left_y+left_h, left_x:left_x+left_w]
            
    top_mean0 = int(cropTop[:,:,0].mean())
    top_mean1 = int(cropTop[:,:,1].mean())
    top_mean2 = int(cropTop[:,:,2].mean())
    left_mean0 = int(cropLeft[:,:,0].mean())
    left_mean1 = int(cropLeft[:,:,1].mean())
    left_mean2 = int(cropLeft[:,:,2].mean())

    min_error = 10000000
    gym_id = 0
    gym_image_id = 0

    LOG.info('Gyms in gym_images: {}'.format(len(gym_db)))
    LOG.debug('top_mean0:{} top_mean1:{} top_mean2:{} left_mean0:{} left_mean1:{} left_mean2:{} '.format(top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2))

    for gym in gym_db:
        dif1 = pow(top_mean0 - gym.param_1,2)
        dif2 = pow(top_mean1 - gym.param_2,2)
        dif3 = pow(top_mean2 - gym.param_3,2)
        dif4 = pow(left_mean0 - gym.param_4,2)
        dif5 = pow(left_mean1 - gym.param_5,2)
        dif6 = pow(left_mean2 - gym.param_6,2)
        error = math.sqrt(dif1+dif2+dif3+dif4+dif5+dif6)
#        print(gym.fort_id,error,gym.param_1,gym.param_2,gym.param_3,gym.param_4,gym.param_5,gym.param_6)
        # find minimum error
        if error < min_error:
            min_error = error
            gym_id = gym.fort_id
            gym_image_id = gym.id

    if min_error > 10:
        LOG.info('gym_id:{} min_error:{}'.format(gym_id, min_error))
        LOG.info('GymImage added to database')
        gym_id = -1
        database.add_gym_image(session,unknown_fort_id,top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2)
        gym_image_id = database.get_gym_image_id(session,top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2)
        # Reload gym_images
        gym_db = [ gym for gym in database.get_gym_images(session)]
#        for gym in gym_db:
#            LOG.debug('{} {} {} {} {} {} {} {}'.format(gym.id, gym.fort_id, gym.param_1, gym.param_2, gym.param_3, gym.param_4, gym.param_5, gym.param_6))
        LOG.info('GymImage reloaded : {}'.format(len(gym_db)))
        
    return gym_image_id, gym_id, min_error

def get_gym_image_id(raid_img):
    height, width, channels = raid_img.shape
    
    org_top_y = 40
    org_top_h = 30
    org_top_x = 135
    org_top_w = 50
    org_left_y = 125
    org_left_h = 70
    org_left_x = 45
    org_left_w = 25
    
    scale = width/320

    top_y = int(org_top_y*scale)
    top_h = int(org_top_h*scale)
    top_x = int(org_top_x*scale)
    top_w = int(org_top_w*scale)
    left_y = int(org_left_y*scale)
    left_h = int(org_left_h*scale)
    left_x = int(org_left_x*scale)
    left_w = int(org_left_w*scale)
    
    cropTop = raid_img[top_y:top_y+top_h, top_x:top_x+top_w]
    cropLeft = raid_img[left_y:left_y+left_h, left_x:left_x+left_w]
        
    top_mean0 = int(cropTop[:,:,0].mean())
    top_mean1 = int(cropTop[:,:,1].mean())
    top_mean2 = int(cropTop[:,:,2].mean())
    left_mean0 = int(cropLeft[:,:,0].mean())
    left_mean1 = int(cropLeft[:,:,1].mean())
    left_mean2 = int(cropLeft[:,:,2].mean())
    print('gym image param:',top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2)
    gym_image_id = database.get_gym_image_id(session,top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2)
    return gym_image_id

def detectMon(img):
    global mon_db
    ret,bin_img = cv2.threshold(cv2.cvtColor(img,cv2.COLOR_BGR2GRAY),240,255,cv2.THRESH_BINARY_INV)
    bin_color = cv2.cvtColor(bin_img,cv2.COLOR_GRAY2BGR)

    height, width, channels = img.shape
    
    org_x1 = [288, 300]
    org_y1 = [125, 195]
    org_x2 = [264, 280]
    org_y2 = [234, 250]    
    org_x3 = [244, 260]
    org_y3 = [254, 270]    
    org_x4 = [224, 240]
    org_y4 = [270, 286]    
    org_x5 = [310, 318]
    org_y5 = [220, 350]    
    org_x6 = [280, 308]
    org_y6 = [270, 350]    
    org_x7 = [244, 278]
    org_y7 = [300, 350]    

    scale = width/320
    LOG.info('raid image scale :{}'.format(scale))

    x1 = [int(org_x1[0]*scale), int(org_x1[1]*scale)]
    y1 = [int(org_y1[0]*scale), int(org_y1[1]*scale)]
    x2 = [int(org_x2[0]*scale), int(org_x2[1]*scale)]
    y2 = [int(org_y2[0]*scale), int(org_y2[1]*scale)]    
    x3 = [int(org_x3[0]*scale), int(org_x3[1]*scale)]
    y3 = [int(org_y3[0]*scale), int(org_y3[1]*scale)]    
    x4 = [int(org_x4[0]*scale), int(org_x4[1]*scale)]
    y4 = [int(org_y4[0]*scale), int(org_y4[1]*scale)]    
    x5 = [int(org_x5[0]*scale), int(org_x5[1]*scale)]
    y5 = [int(org_y5[0]*scale), int(org_y5[1]*scale)]    
    x6 = [int(org_x6[0]*scale), int(org_x6[1]*scale)]
    y6 = [int(org_y6[0]*scale), int(org_y6[1]*scale)]    
    x7 = [int(org_x7[0]*scale), int(org_x7[1]*scale)]
    y7 = [int(org_y7[0]*scale), int(org_y7[1]*scale)]    
    
    crop1 = bin_img[y1[0]:y1[1], x1[0]:x1[1]]
    crop2 = bin_img[y2[0]:y2[1], x2[0]:x2[1]]
    crop3 = bin_img[y3[0]:y3[1], x3[0]:x3[1]]
    crop4 = bin_img[y4[0]:y4[1], x4[0]:x4[1]]
    crop5 = bin_img[y5[0]:y5[1], x5[0]:x5[1]]
    crop6 = bin_img[y6[0]:y6[1], x6[0]:x6[1]]
    crop7 = bin_img[y7[0]:y7[1], x7[0]:x7[1]]

    mean1 = int(crop1.mean())
    mean2 = int(crop2.mean())
    mean3 = int(crop3.mean())
    mean4 = int(crop4.mean())
    mean5 = int(crop5.mean())
    mean6 = int(crop6.mean())
    mean7 = int(crop7.mean())
    
    min_error = 10000000
    mon_id = 0
    mon_image_id = 0
    
    # get error from all gyms
    for mon in mon_db:
        dif1 = pow(mean1 - mon.param_1,2)
        dif2 = pow(mean2 - mon.param_2,2)
        dif3 = pow(mean3 - mon.param_3,2)
        dif4 = pow(mean4 - mon.param_4,2)
        dif5 = pow(mean5 - mon.param_5,2)
        dif6 = pow(mean6 - mon.param_6,2)
        dif7 = pow(mean7 - mon.param_7,2)
        error = math.sqrt(dif1+dif2+dif3+dif4+dif5+dif6+dif7)
        # find minimum error
        if error < min_error:
            min_error = error
            mon_id = mon.pokemon_id
            mon_image_id = mon.id

    if min_error > 5:
        mon_id = -1
        database.add_pokemon_image(session,0,mean1,mean2,mean3,mean4,mean5,mean6,mean7)
        mon_image_id = database.get_pokemon_image_id(session,mean1,mean2,mean3,mean4,mean5,mean6,mean7)
        # Reload pokemon_images
        mon_db = [ mon for mon in database.get_pokemon_images(session)]

    return mon_image_id, mon_id, min_error

def get_pokemon_image_id(img):
    ret,bin_img = cv2.threshold(cv2.cvtColor(img,cv2.COLOR_BGR2GRAY),240,255,cv2.THRESH_BINARY_INV)
    bin_color = cv2.cvtColor(bin_img,cv2.COLOR_GRAY2BGR)
    
    height, width, channels = img.shape
    
    org_x1 = [288, 300]
    org_y1 = [125, 195]
    org_x2 = [264, 280]
    org_y2 = [234, 250]    
    org_x3 = [244, 260]
    org_y3 = [254, 270]    
    org_x4 = [224, 240]
    org_y4 = [270, 286]    
    org_x5 = [310, 318]
    org_y5 = [220, 350]    
    org_x6 = [280, 308]
    org_y6 = [270, 350]    
    org_x7 = [244, 278]
    org_y7 = [300, 350]    

    scale = width/320

    x1 = [int(org_x1[0]*scale), int(org_x1[1]*scale)]
    y1 = [int(org_y1[0]*scale), int(org_y1[1]*scale)]
    x2 = [int(org_x2[0]*scale), int(org_x2[1]*scale)]
    y2 = [int(org_y2[0]*scale), int(org_y2[1]*scale)]    
    x3 = [int(org_x3[0]*scale), int(org_x3[1]*scale)]
    y3 = [int(org_y3[0]*scale), int(org_y3[1]*scale)]    
    x4 = [int(org_x4[0]*scale), int(org_x4[1]*scale)]
    y4 = [int(org_y4[0]*scale), int(org_y4[1]*scale)]    
    x5 = [int(org_x5[0]*scale), int(org_x5[1]*scale)]
    y5 = [int(org_y5[0]*scale), int(org_y5[1]*scale)]    
    x6 = [int(org_x6[0]*scale), int(org_x6[1]*scale)]
    y6 = [int(org_y6[0]*scale), int(org_y6[1]*scale)]    
    x7 = [int(org_x7[0]*scale), int(org_x7[1]*scale)]
    y7 = [int(org_y7[0]*scale), int(org_y7[1]*scale)]    
    
    crop1 = bin_img[y1[0]:y1[1], x1[0]:x1[1]]
    crop2 = bin_img[y2[0]:y2[1], x2[0]:x2[1]]
    crop3 = bin_img[y3[0]:y3[1], x3[0]:x3[1]]
    crop4 = bin_img[y4[0]:y4[1], x4[0]:x4[1]]
    crop5 = bin_img[y5[0]:y5[1], x5[0]:x5[1]]
    crop6 = bin_img[y6[0]:y6[1], x6[0]:x6[1]]
    crop7 = bin_img[y7[0]:y7[1], x7[0]:x7[1]]

    mean1 = int(crop1.mean())
    mean2 = int(crop2.mean())
    mean3 = int(crop3.mean())
    mean4 = int(crop4.mean())
    mean5 = int(crop5.mean())
    mean6 = int(crop6.mean())
    mean7 = int(crop7.mean())

    print('pokemon image param:',mean1,mean2,mean3,mean4,mean5,mean6,mean7)
    pokemon_image_id = database.get_pokemon_image_id(session,mean1,mean2,mean3,mean4,mean5,mean6,mean7)
    return pokemon_image_id

def detectEgg(data):
    if data[:7] == 'Ongoing' or data[:4] == 'Raid' or data == '':
        return False
    else:
        return True

def getHatchTime(data):
    zero = datetime.datetime.now().replace(hour=0,minute=0,second=0,microsecond=0)
    unix_zero = zero.timestamp()
    LOG.info('hatch_time ={}'.format(data))
    # US format
    AM = data.find('AM')
    if AM >= 5:
        hour_min = data[:AM-1].split(':')
        return int(unix_zero)+int(hour_min[0])*3600+int(hour_min[1])*60
    PM = data.find('PM')
    if PM >= 5:
        hour_min = data[:PM-1].split(':')
        if hour_min[0] == '12':
            return int(unix_zero)+int(hour_min[0])*3600+int(hour_min[1])*60
        else:
            return int(unix_zero)+(int(hour_min[0])+12)*3600+int(hour_min[1])*60
    # Europe format
    

def isRaidSighting(img):
    ret = True
    LOG.debug('image mean :{}'.format(img.mean()))
    if int(img.mean()) > 240:
        LOG.debug('No raid sightings')
        ret = False
    return ret

def processRaidImage(raidfilename):
    filename = os.path.basename(raidfilename)
    img_full = cv2.imread(str(raidfilename),3)

    now = datetime.datetime.now()
    unix_time = int(now.timestamp())
    file_update_time = int(os.stat(str(raidfilename)).st_mtime)
    LOG.debug('Image was created {} seconds ago'.format(str(unix_time-file_update_time)))

    if isRaidSighting(img_full) == False:
        os.remove(raidfilename)
        return False

    x1 = [0, 319]
    y1 = [406, 450]
    time_img = img_full[y1[0]:y1[1], x1[0]:x1[1]]    
    #cv2.rectangle(img_egg,(x1[0],y1[0]),(x1[1],y1[1]),(0,255,0),1)

    x2 = [0, 319]
    y2 = [476, 524]
    level_img = img_full[y2[0]:y2[1], x2[0]:x2[1]]    
    #cv2.rectangle(img_egg,(x2[0],y2[0]),(x2[1],y2[1]),(0,255,0),1)    

    time_text = detectTime(time_img)
    level = detectLevel(level_img)
    gym_image_id, gym, error_gym = detectGym(img_full)
    egg = detectEgg(time_text)

    update_raid = True    
    # old file
    if unix_time - file_update_time > 1800:
        LOG.info('File is too old')
        update_raid = False
    if int(gym) > 0 and int(gym) != not_a_fort_id and int(gym) != unknown_fort_id:
        if egg == True:
            hatch_time = getHatchTime(time_text)
            spawn_time = hatch_time - 3600
            end_time = hatch_time + 2700
            time_battle = database.get_raid_battle_time(session, gym)
            LOG.info('Egg: level={} time_text={} gym={} error_gym={} hatch_time={} time_battle={}'.format(level, time_text, gym, error_gym, hatch_time, time_battle))
            if update_raid == True:
                if int(time_battle) == int(hatch_time):
                    LOG.info('This Egg is already assigned.')
                else:
                    database.update_raid_egg(session, gym, level, hatch_time)
                    database.updata_fort_sighting(session, gym, unix_time)
                    LOG.info('New Egg is added.')
            else:
                LOG.info('Skip update raid due to old file')
        else:
            mon_image_id, mon, error_mon = detectMon(img_full)
            pokemon_id = database.get_raid_pokemon_id(session, gym)
            LOG.info('Pokemon: level={} time_text={} gym={} error_gym={} mon={} error_mon={}'.format(level, time_text, gym, error_gym, mon, error_mon))
            LOG.info('mon:{} pokemon_id:{}'.format(mon,pokemon_id))
            if int(mon) == int(pokemon_id) and int(mon) > 0:
                LOG.info('This mon is already assigned.')
            else:            
                if int(mon) > 0:
                    if update_raid == True:
                        database.update_raid_mon(session, gym, mon)
                        database.updata_fort_sighting(session, gym, unix_time)
                        LOG.info('New raid boss is added.')
                    else:
                        LOG.info('Skip update raid due to old file')
                elif int(mon) == 0:
                    LOG.info('Pokemon image params are in database but the Pokemon is not known')
                    unknown_mon_name = 'PokemonImage_'+str(mon_image_id)+'.png'
                    fullpath_dest = str(not_find_path) + str(unknown_mon_name)
                    LOG.info(fullpath_dest)
                    shutil.copy2(raidfilename,fullpath_dest)
                else: # int(mon) < 0
                    # Send mon image for training directory
                    LOG.info('Mon is not in database')
                    unknown_mon_name = 'PokemonImage_'+str(mon_image_id)+'.png'
                    fullpath_dest = str(not_find_path) + str(unknown_mon_name)
                    LOG.info(fullpath_dest)
                    shutil.copy2(raidfilename,fullpath_dest)
                    
    elif int(gym) == not_a_fort_id:
        LOG.info('Raid image is not valid')
    elif int(gym) == unknown_fort_id and egg == True:
        # Send Image to Training Directory
        LOG.info('Gym image params are in database but the Gym is not known')
        unknown_gym_name = 'GymImage_'+str(gym_image_id)+'.png'
        fullpath_dest = str(copy_path) + str(unknown_gym_name)
        LOG.info(fullpath_dest)
        shutil.copy2(raidfilename,fullpath_dest)
    elif int(gym) == -1 and egg == True: # int(gym) < 0
        # Send gym image for training directory
        unknown_gym_name = 'GymImage_'+str(gym_image_id)+'.png'
        fullpath_dest = str(copy_path) + str(unknown_gym_name)
        LOG.info(fullpath_dest)
        shutil.copy2(raidfilename,fullpath_dest)

    os.remove(raidfilename)

    #cv2.imshow('raid_image', img_full)
    #cv2.waitKey(0)
    return True

def main():
    while True:
        for fullpath_filename in p.glob('*.png'):
            processRaidImage(fullpath_filename)
        time.sleep(3)
    session.close()

if __name__ == '__main__':
    main()


