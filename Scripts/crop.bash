#!/bin/bash

while true

IMAEG_NAME="raid-map"

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

		if [ "$HASH" == "235e2af860fe01bd3da8809d897b31bb" ]
		then
			mkdir inbox

			cp ImageInput.png ImageMon1.png
			mogrify -crop "$MON_SIZE"+"$MON_X1"+"$MON_Y1" -strip +repage ImageMon1.png
			cp ImageInput.png ImageMon2.png
			mogrify -crop "$MON_SIZE"+"$MON_X2"+"$MON_Y1" -strip +repage ImageMon2.png
			cp ImageInput.png ImageMon3.png
			mogrify -crop "$MON_SIZE"+"$MON_X3"+"$MON_Y1" -strip +repage ImageMon3.png
			cp ImageInput.png ImageMon4.png
			mogrify -crop "$MON_SIZE"+"$MON_X1"+"$MON_Y2" -strip +repage ImageMon4.png
			cp ImageInput.png ImageMon5.png
			mogrify -crop "$MON_SIZE"+"$MON_X2"+"$MON_Y2" -strip +repage ImageMon5.png
			cp ImageInput.png ImageMon6.png
			mogrify -crop "$MON_SIZE"+"$MON_X3"+"$MON_Y2" -strip +repage ImageMon6.png

			cp ImageInput.png ImageTime1.png
			mogrify -crop "$TIME_SIZE"+"$TIME_X1"+"$TIME_Y1" -strip +repage ImageTime1.png
			convert ImageTime1.png ImageTime1.tif
			cp ImageInput.png ImageTime2.png
			mogrify -crop "$TIME_SIZE"+"$TIME_X2"+"$TIME_Y1" -strip +repage ImageTime2.png
			convert ImageTime2.png ImageTime2.tif
			cp ImageInput.png ImageTime3.png
			mogrify -crop "$TIME_SIZE"+"$TIME_X3"+"$TIME_Y1" -strip +repage ImageTime3.png
			convert ImageTime3.png ImageTime3.tif
			cp ImageInput.png ImageTime4.png
			mogrify -crop "$TIME_SIZE"+"$TIME_X1"+"$TIME_Y2" -strip +repage ImageTime4.png
			convert ImageTime4.png ImageTime4.tif
			cp ImageInput.png ImageTime5.png
			mogrify -crop "$TIME_SIZE"+"$TIME_X2"+"$TIME_Y2" -strip +repage ImageTime5.png
			convert ImageTime5.png ImageTime5.tif
			cp ImageInput.png ImageTime6.png
			mogrify -crop "$TIME_SIZE"+"$TIME_X3"+"$TIME_Y2" -strip +repage ImageTime6.png

			convert ImageTime6.png ImageTime6.tif

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

			cp ImageInput.png ImageLevel1.png
			mogrify -crop "$LEVEL_SIZE"+"$LEVEL_X1"+"$LEVEL_Y1" -strip +repage ImageLevel1.png
			convert ImageLevel1.png ImageLevel1.tif
			cp ImageInput.png ImageLevel2.png
			mogrify -crop "$LEVEL_SIZE"+"$LEVEL_X2"+"$LEVEL_Y1" -strip +repage ImageLevel2.png
			convert ImageLevel2.png ImageLevel2.tif
			cp ImageInput.png ImageLevel3.png
			mogrify -crop "$LEVEL_SIZE"+"$LEVEL_X3"+"$LEVEL_Y1" -strip +repage ImageLevel3.png
			convert ImageLevel3.png ImageLevel3.tif
			cp ImageInput.png ImageLevel4.png
			mogrify -crop "$LEVEL_SIZE"+"$LEVEL_X1"+"$LEVEL_Y2" -strip +repage ImageLevel4.png
			convert ImageLevel4.png ImageLevel4.tif
			cp ImageInput.png ImageLevel5.png
			mogrify -crop "$LEVEL_SIZE"+"$LEVEL_X2"+"$LEVEL_Y2" -strip +repage ImageLevel5.png
			convert ImageLevel5.png ImageLevel5.tif
			cp ImageInput.png ImageLevel6.png
			mogrify -crop "$LEVEL_SIZE"+"$LEVEL_X3"+"$LEVEL_Y2" -strip +repage ImageLevel6.png
			convert ImageLevel6.png ImageLevel6.tif

			HASH1=$(md5 -q ImageFull1.png)
			HASH2=$(md5 -q ImageFull2.png)
			HASH3=$(md5 -q ImageFull3.png)
			HASH4=$(md5 -q ImageFull4.png)
			HASH5=$(md5 -q ImageFull5.png)
			HASH6=$(md5 -q ImageFull6.png)

			HASH1MON=$(md5 -q ImageMon1.png)
			HASH2MON=$(md5 -q ImageMon2.png)
			HASH3MON=$(md5 -q ImageMon3.png)
			HASH4MON=$(md5 -q ImageMon4.png)
			HASH5MON=$(md5 -q ImageMon5.png)
			HASH6MON=$(md5 -q ImageMon6.png)
			
			if [ ! -d "Output-Temp/$HASH1" ]; then
				mkdir "Output-Temp/$HASH1"
				mv ImageMon1.png "Output-Temp/$HASH1"/"$HASH1MON".png
				tesseract ImageTime1.tif "Output-Temp/$HASH1"/time &>/dev/null
				tesseract ImageLevel1.tif "Output-Temp/$HASH1"/level &>/dev/null
				mv ImageFull1.png "Output-Temp/$HASH1"/Full.png
			fi
			if [ ! -d "Output-Temp/$HASH2" ]; then
				mkdir "Output-Temp/$HASH2"
				mv ImageMon2.png "Output-Temp/$HASH2"/"$HASH2MON".png
				tesseract ImageTime2.tif "Output-Temp/$HASH2"/time &>/dev/null
				tesseract ImageLevel2.tif "Output-Temp/$HASH2"/level &>/dev/null
				mv ImageFull2.png "Output-Temp/$HASH2"/Full.png
			fi
			if [ ! -d "Output-Temp/$HASH3" ]; then
				mkdir "Output-Temp/$HASH3"
				mv ImageMon3.png "Output-Temp/$HASH3"/"$HASH3MON".png
				tesseract ImageTime3.tif "Output-Temp/$HASH3"/time &>/dev/null
				tesseract ImageLevel3.tif "Output-Temp/$HASH3"/level &>/dev/null
				mv ImageFull3.png "Output-Temp/$HASH3"/Full.png
			fi
			if [ ! -d "Output-Temp/$HASH4" ]; then
				mkdir "Output-Temp/$HASH4"
				mv ImageMon4.png "Output-Temp/$HASH4"/"$HASH4MON".png
				tesseract ImageTime4.tif "Output-Temp/$HASH4"/time &>/dev/null
				tesseract ImageLevel4.tif "Output-Temp/$HASH4"/level &>/dev/null
				mv ImageFull4.png "Output-Temp/$HASH4"/Full.png
			fi
			if [ ! -d "Output-Temp/$HASH5" ]; then
				mkdir "Output-Temp/$HASH5"
				mv ImageMon5.png "Output-Temp/$HASH5"/"$HASH5MON".png
				tesseract ImageTime5.tif "Output-Temp/$HASH5"/time &>/dev/null
				tesseract ImageLevel5.tif "Output-Temp/$HASH5"/level &>/dev/null
				mv ImageFull5.png "Output-Temp/$HASH5"/Full.png
			fi
			if [ ! -d "Output-Temp/$HASH6" ]; then
				mkdir "Output-Temp/$HASH6"
				mv ImageMon6.png "Output-Temp/$HASH6"/"$HASH6MON".png
				tesseract ImageTime6.tif "Output-Temp/$HASH6"/time &>/dev/null
				tesseract ImageLevel6.tif "Output-Temp/$HASH6"/level &>/dev/null
				mv ImageFull6.png "Output-Temp/$HASH6"/Full.png
			fi

			mv Output-Temp/* inbox &>/dev/null
			docker cp inbox "$IMAEG_NAME":/perfect-deployed/raid-map/
			rm -rf inbox
		fi
	fi
	rm -r -r Output-Temp
	rm -f *.png
	rm -f *.tif
	sleep 0.1
done
