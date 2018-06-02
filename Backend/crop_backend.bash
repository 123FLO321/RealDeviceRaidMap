#!/bin/bash

while true

RDRM_HOME_PATH="/Path/to/RealDeviceRaidMap/"

do
	mkdir Output-Temp &>/dev/null
    mkdir Input &>/dev/null
    mv ~/Library/Developer/Xcode/DerivedData/RDRaidMapCtrl-*/Logs/Test/Attachments/*.png Input &>/dev/null
    rm -f ~/Library/Developer/Xcode/DerivedData/RDRaidMapCtrl-*/Logs/Test/Attachments/*.jpg &>/dev/null
	FILE=$(ls Input | head -1)
	if [ "$FILE" != "" ]
	then
		mv "Input/$FILE" ImageInput.png
		
		WIDTH=$(identify -format "%w" "ImageInput.png")> /dev/null

		if [ "$WIDTH" == "750" ] #iPhone
		then			
			MON_SIZE="84x84"
			MON_X1=119
			MON_X2=338
			MON_X3=556
			MON_Y1=555
			MON_Y2=878
			
			TIME_SIZE="157x30"
			TIME_X1=83
			TIME_X2=302
			TIME_X3=520
			TIME_Y1=712
			TIME_Y2=1035
			
			FULL_SIZE="157x260"
			FULL_X1=83
			FULL_X2=302
			FULL_X3=520
			FULL_Y1=519
			FULL_Y2=842
			
			LEVEL_SIZE="157x30"
			LEVEL_X1=83
			LEVEL_X2=302
			LEVEL_X3=520
			LEVEL_Y1=749
			LEVEL_Y2=1072
			
			COMPARE_X=85
			COMPARE_Y=595
		elif [ "$WIDTH" == "1536" ]
		then			
			MON_SIZE="172x172"
			MON_X1=244
			MON_X2=692
			MON_X3=1140
			MON_Y1=453
			MON_Y2=1115
			
			TIME_SIZE="320x45"
			TIME_X1=170
			TIME_X2=618
			TIME_X3=1066
			TIME_Y1=785
			TIME_Y2=1447
			
			FULL_SIZE="320x525"
			FULL_X1=170
			FULL_X2=618
			FULL_X3=1066
			FULL_Y1=379
			FULL_Y2=1041
			
			LEVEL_SIZE="320x60"
			LEVEL_X1=170
			LEVEL_X2=618
			LEVEL_X3=1066
			LEVEL_Y1=855
			LEVEL_Y2=1517
			
			COMPARE_X=175
			COMPARE_Y=535
		fi

		cp ImageInput.png ImageCompare.png
		mogrify -crop 1x1+"$COMPARE_X"+"$COMPARE_Y" -strip +repage ImageCompare.png
		HASH=$(md5 -q ImageCompare.png)

		echo "$HASH"

		if [ "$HASH" == "235e2af860fe01bd3da8809d897b31bb" ]
		then
            cp ImageInput.png ImageFull1.png
            mogrify -crop "$FULL_SIZE"+"$FULL_X1"+"$FULL_Y1" -strip +repage ImageFull1.png
            cp ImageInput.png ImageFull2.png
            mogrify -crop "$FULL_SIZE"+"$FULL_X2"+"$FULL_Y1" -strip +repage ImageFull2.png
            cp ImageInput.png ImageFull3.png
            mogrify -crop "$FULL_SIZE"+"$FULL_X3"+"$FULL_Y1" -strip +repage ImageFull3.png
            cp ImageInput.png ImageFull4.png
            mogrify -crop "$FULL_SIZE"+"$FULL_X1"+"$FULL_Y2" -strip +repage ImageFull4.png
            cp ImageInput.png ImageFull5.png
            mogrify -crop "$FULL_SIZE"+"$FULL_X2"+"$FULL_Y2" -strip +repage ImageFull5.png
            cp ImageInput.png ImageFull6.png
            mogrify -crop "$FULL_SIZE"+"$FULL_X3"+"$FULL_Y2" -strip +repage ImageFull6.png

            mv ImageFull1.png "$RDRM_HOME_PATH"Backend/process_img/"$FILE"01.png
            mv ImageFull2.png "$RDRM_HOME_PATH"Backend/process_img/"$FILE"02.png
            mv ImageFull3.png "$RDRM_HOME_PATH"Backend/process_img/"$FILE"03.png
            mv ImageFull4.png "$RDRM_HOME_PATH"Backend/process_img/"$FILE"04.png
            mv ImageFull5.png "$RDRM_HOME_PATH"Backend/process_img/"$FILE"05.png
            mv ImageFull6.png "$RDRM_HOME_PATH"Backend/process_img/"$FILE"06.png

		fi
	fi
	rm -f *.png
	rm -f *.tif
	sleep 0.1
done
