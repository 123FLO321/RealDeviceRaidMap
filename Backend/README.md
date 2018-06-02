# RealDeviceRaidMap Backend
Backend for RealDeviceRaidMap. Identify Gym from Gym image and post extracted information to monocle hydro database. Most of gym iamges are identified automatically.

## Setting up
1. Install Python 3.6
2. Create venv
	`python3.6 -m venv path/to/create/venv`
	example: `python3.6 -m venv ~/venv_rdrm`
3. Activate venv
	`source ~/venv_rdrm/bin/activate`
4. Install requirements
	`pip3.6 install -r requirements.txt -U`
	* If you don't have MySQL on your machine, comment out mysqlclient
	* If you don't have Postgresql on your machine, commment out psycopg2 and psycopg2-binary
5. Configure config.py to set your monocle database
6. Run `python3.6 raidscan.py` from the command line
7. Open another terminal and activate venv as in step 3
8. Run `python3.6 downloadfortimg.py`. If you don't want to download whole fort image in database set `MAP_START` and `MAP_END`.
9. 
