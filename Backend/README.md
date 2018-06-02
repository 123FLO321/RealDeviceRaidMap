# RealDeviceRaidMap Backend
Backend for RealDeviceRaidMap. Identify Gym from Gym image and post extracted information to monocle hydro database. Most of gym iamges are identified automatically.

## Features
1. Read raid sightings images and identify
	* gym 
	* raid boss
	* start time
2. Parameters to identify gym and raid boss are stored in gym_images and pokemon_images table automatically.
3. Update raids and fort_sightings tables in monocle (Hydro) database
4. Download gym(fort) url images and find matching gym automatically. Up to 99% of gyms are detected successfully.
5. MySQL and Postgresql supported.

## How it works
### raidscan.py
Read all raid sightings png images cropped by `crop_backend.bash` in `process_img` directory and extract gym/raid boss/hatch time information and update `raids` and `fort_sightings` table for monocle Hydro database. If raidscan.py can't identify the gym then the gym image is stored in `unknown_img` as `FortImage_xxx.png`. Once gym is identified, check level and time. If time is Ongoing, then try to identify raid boss by checking `pokemon_images` table. If the raid boss is unknown, then store the raid boss image into `unknow_img` as PokemonImage_xxx.png.

### findfort.py
Read all gym images in `unknown_img` and identify the gym image by comparing fort URL images in `url_img`. If findfort.py finds matching gym(fort) in `url_img`, then update `gym_images` table to set identified `fort_id`. findfort.py checks images every 30 seconds. Fort URL images need to be downloaded by `downloadfortimg.py` before running `findfort.py`.

### downloadfortimg.py
Download all fort URL images in `Forts` table. Set `MAP_START` and `MAP_END` in `config.py` to limit fort URL images to download if you want.

### manualsubmit.py
`manualsubmit.py` update `fort_id` in `gym_images` and `pokemon_id` in `pokemon_images` by reading `Fort_xxx.png` and `Pokemon_yyy.png` in `not_find_img`. User need to set xxx for `fort_id` and yyy for `pokemon_id` manually. This part need to be integrated with `Frontend` in the future.

### Running order
1. Run `python3.6 downloadfortimg.py` once to download all gym(fort) URL image
2. Run `python3.6 raidscan.py` to scan raid images
3. Run `python3.6 findfort.py` to find gym if there is unknow gym
4. Run `python3.6 manualsubmit.py` once you set `Fort_xxx.png` and `Pokemon_yyy.png` in `not_find_img` directory.

## Setting up
1. Install Python 3.6 (<https://www.python.org/downloads/release/python-365/>)
2. Install imagemagick 7+ `brew install imagemagick`
3. Install tesseract `brew install tesseract`
4. Create venv
    `python3.6 -m venv path/to/create/venv`
	example: `python3.6 -m venv ~/venv_rdrm`
5. Activate venv
    `source ~/venv_rdrm/bin/activate`
6. Install requirements
    `pip3.6 install -r requirements.txt -U`
    * If you don't have MySQL on your machine, comment out mysqlclient
    * If you don't have Postgresql on your machine, commment out psycopg2 and psycopg2-binary
7. Configure config.py to set your monocle database
8. Run `python3.6 raidscan.py` from the command line. When first run, raid_images and pokemon_images tables are added automatically.
9. Open another terminal and activate venv as in step 3
10. Run `python3.6 downloadfortimg.py`. If you don't want to download whole fort images in database, set `MAP_START` and `MAP_END` in `config.py`.
11. Wait finish download fort images, then run `python3.6 findfort.py`
12. Open crop_backend.bash and edit `RDRM_HOME_PATH` to your RealDeviceRaidMap directory.
13. Run `bach crop_backend.bash`. **Note. Currently Backend can't run with Frontend so Stop crop.bash before running crop_backend.bash**. Don't worry, Backend can identify gym images up to 99% of gyms automatically (without user input).
14. Wait until all gyms are identified. Check `success_img` and `need_check_img` directory to make sure all gym images are correctly identified.
15. `PokemonImage_xxx.png` files are stored in `unknown_img` directory. Rename the file to `Pokemon_PokemonId.png`(e.g. `Pokemon_380.png` for Latias) and run `python3.6 manualsubmit.py`. This will train pokemon raid boss. Usually only one time training should be enough.
