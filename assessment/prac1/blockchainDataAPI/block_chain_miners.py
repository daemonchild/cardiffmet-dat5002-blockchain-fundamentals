import requests
import json
import os
from colorama import Fore, Back, Style

# Reference: https://github.com/bitcoin-data/mining-pools/

# Fetch the Mining Pool Data from GitHub and combine into a single json file
def fetch_mining_pool_data(force=False):

    _mining_pool_json_file = "mining_pools.json"
    
    _module_path = os.path.dirname(os.path.abspath(__file__))
    _filepath=_module_path + "/" + _mining_pool_json_file

    # Only if the file does not exist and we are not forcing the rebuild
    if os.path.exists(_filepath):
        if not force:
            return
    
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

    # Save combined result
    with open(_filepath, "w") as f:
        json.dump(_combined_data, f, indent=4)



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
