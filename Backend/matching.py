import cv2
import os

def fort_image_matching(url_img_name, fort_img_name):
    url_img = cv2.imread(url_img_name,3)
    fort_img = cv2.imread(fort_img_name,3)

    height, width, channels = url_img.shape
    
    if width > height:
        scale = float(288/height)
    else:
        scale = float(288/width)
        
    if scale < 0.98 or scale > 1.02:
        url_img = cv2.resize(url_img,None,fx=scale, fy=scale, interpolation = cv2.INTER_NEAREST)

    crop = fort_img[74:246,74:144]

    # Calculate center of fort image(x=74, y=74, width=172, height=172) of fort_img
    fi_center_x = (246-74)/2
    fi_center_y = (246-74)/2

    if crop.mean() == 255 or crop.mean() == 0:
        return 0.0

    result = cv2.matchTemplate(url_img, crop, cv2.TM_CCOEFF_NORMED)
    min_val3, max_val3, min_loc3, max_loc3 = cv2.minMaxLoc(result)

    # Calculate x y distance between max_loc3 and center of url_img
    height, width, channels = url_img.shape    
    ui_center_x = width/2-max_loc3[0]
    ui_center_y = height/2-max_loc3[1]
    
    dif_x = abs(ui_center_x - fi_center_x)
    dif_y = abs(ui_center_y - fi_center_y)
    
    if dif_x > 5 or dif_y >5:
        return 0.0

    return max_val3

def fort_image_matching_imshow(url_img_name, fort_img_name):
    url_img = cv2.imread(url_img_name,3)
    fort_img = cv2.imread(fort_img_name,3)

    height, width, channels = url_img.shape
    
    if width > height:
        scale = float(288/height)
    else:
        scale = float(288/width)
        
    if scale < 0.98 or scale > 1.02:
        url_img = cv2.resize(url_img,None,fx=scale, fy=scale, interpolation = cv2.INTER_NEAREST)

    #crop = fort_img[74:246,74:246]
    crop = fort_img[74:246,74:144]
    
    fi_center_x = (246-74)/2
    fi_center_y = (246-74)/2

    if crop.mean() == 255 or crop.mean() == 0:
        return 0.0

    result = cv2.matchTemplate(url_img, crop, cv2.TM_CCOEFF_NORMED)
    min_val3, max_val3, min_loc3, max_loc3 = cv2.minMaxLoc(result)
    

    height, width, channels = url_img.shape
    
    ui_center_x = width/2-max_loc3[0]
    ui_center_y = height/2-max_loc3[1]
 
    dif_x = abs(ui_center_x - fi_center_x)
    dif_y = abs(ui_center_y - fi_center_y)    
    print(dif_x, dif_y)
    
    top_left = max_loc3
    height, width, channels = crop.shape
    bottom_right = (top_left[0] + width, top_left[1] + height)
    cv2.rectangle(url_img,top_left, bottom_right, (0, 255, 0), 2)
    cv2.rectangle(fort_img,(74,74), (144, 246), (0, 0, 255), 2)

    cv2.imshow('matching result', url_img)
#    cv2.imshow('tmp', fort_img)
    cv2.imshow('crop', crop)
    cv2.waitKey(0)

    if dif_x > 5 or dif_y >5:
        return 0.0   

    return max_val3


if __name__ == '__main__':
    fort_id = 432
    url_img_path = os.getcwd() + '/success_img/Fort_' + str(fort_id) + '_url.jpg'
    fort_img_path = os.getcwd() + '/success_img/Fort_' + str(fort_id) + '.png'
    print(url_img_path)
    print(fort_img_path)
    print(fort_image_matching_imshow(url_img_path,fort_img_path))
#    print(fort_image_matching('/home/mizu/raidimage/GymMonDetectionPostgres/url_image/1.jpg','/home/mizu/raidimage/GymMonDetectionPostgres/Training/GymImage_82.png'))
#    print(fort_image_matching_imshow('/Users/akira/raidimage/GymMonDetectionPostgres/success_img/Fort_103_url.jpg','/Users/akira/raidimage/GymMonDetectionPostgres/success_img/Fort_103.png'))


