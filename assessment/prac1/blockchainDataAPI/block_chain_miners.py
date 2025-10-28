#  __  _____   ____   ___ ____  ___    ____ ____  _ _____           _____                    __                          
# / _\/__   \ |___ \ / _ \___ \( _ )  | ___|___ \/ |___ /          /__   \___  _ __ ___     /__\ _____      ____ _ _ __  
# \ \   / /\/   __) | | | |__) / _ \  |___ \ __) | | |_ \   _____    / /\/ _ \| '_ ` _ \   / \/// _ \ \ /\ / / _` | '_ \ 
# _\ \ / /     / __/| |_| / __/ (_) |  ___) / __/| |___) | |_____|  / / | (_) | | | | | | / _  \ (_) \ V  V / (_| | | | |
# \__/ \/     |_____|\___/_____\___/  |____/_____|_|____/           \/   \___/|_| |_| |_| \/ \_/\___/ \_/\_/ \__,_|_| |_|
#                                                                                                                       
#
#  	Title:		            Bitcoin Miners
#   Uses:                   https://github.com/bitcoin-data/mining-pools/
#   Repo Accessed:          22/10/2025
# 

import requests
import json
import os
from datetime import datetime, timedelta
from colorama import Fore, Style

# Fetch the Mining Pool Data from GitHub and combine into a single json file
def fetch_mining_pool_data():

    _mining_pool_json_file = "mining_pools.json"
    
    _module_path = os.path.dirname(os.path.abspath(__file__))
    _filepath=_module_path + "/" + _mining_pool_json_file

    # Check whether the file exists, if so is it under a month old?
    # If so, exit. Otherwise rebuild.
    if os.path.exists(_filepath):
        # get the date from the file
        _json_data = load_mining_pool_data()
        _file_date = datetime.strptime(_json_data['header']['date'], "%Y-%m-%d %H:%M:%S")

        # Get current time
        now = datetime.now()

        # Check if the file is 30 days old, if not exit
        if now - _file_date < timedelta(days=30):
            return
    
    # Rebuild the mining pool data
    print (Fore.CYAN + "Wait! Getting Mining Pool Data" + Style.RESET_ALL)
    # GitHub API URL to list folder contents
    _api_url = f"https://api.github.com/repos/bitcoin-data/mining-pools/contents/pools?ref=master"

    # Define headers
    _headers = {
        "Accept": "application/vnd.github.v3+json"
    }

    # Zero the combined data
    _combined_data = {}

    # Use API to fetch file list
    _response = requests.get(_api_url, headers=_headers)
    if _response.status_code == 200:    
        for _file in _response.json():
            if _file['name'].endswith('.json'):
                _raw_url = _file['download_url']
                _file_response = requests.get(_raw_url)
                if _file_response.status_code == 200:
                    try:
                        _json_data = _file_response.json()
                        _combined_data[_json_data['name']] = _json_data
                    except json.JSONDecodeError:
                        print(f"Error decoding {_file['name']}")

    # Add the date and time so we know when to update this
    _wrapped_data = {
    "header": {
        "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "generated_by": "Tom Rowan, ST20285213"
        },
        "mining_pools": _combined_data
    }

    # Save combined result
    with open(_filepath, "w") as f:
        json.dump(_wrapped_data, f, indent=4)



def load_mining_pool_data():

    _mining_pool_json_file = "mining_pools.json"    
    _module_path = os.path.dirname(os.path.abspath(__file__))
    _filepath=_module_path + "/" + _mining_pool_json_file

    with open(_filepath, "r") as _file:
        return json.load(_file)


def search_miner_address(address,json_data):

    # Search for matching address
    for _key, _info in json_data.items():
        if address in _info.get("addresses", []):
            return _info['name']
            break
    return "Unknown"
