#  __  _____   ____   ___ ____  ___    ____ ____  _ _____           _____                    __                          
# / _\/__   \ |___ \ / _ \___ \( _ )  | ___|___ \/ |___ /          /__   \___  _ __ ___     /__\ _____      ____ _ _ __  
# \ \   / /\/   __) | | | |__) / _ \  |___ \ __) | | |_ \   _____    / /\/ _ \| '_ ` _ \   / \/// _ \ \ /\ / / _` | '_ \ 
# _\ \ / /     / __/| |_| / __/ (_) |  ___) / __/| |___) | |_____|  / / | (_) | | | | | | / _  \ (_) \ V  V / (_| | | | |
# \__/ \/     |_____|\___/_____\___/  |____/_____|_|____/           \/   \___/|_| |_| |_| \/ \_/\___/ \_/\_/ \__,_|_| |_|
#                                                                                                                       
#
#  	Title:		            Blockchain.Com Data API (BCDA)
#   API Documentation at:   https://www.blockchain.com/explorer/api/blockchain_api
#   Documentation Accessed: 21/10/2025
# 

import requests
import json
import time
from datetime import datetime
from colorama import Fore, Back, Style
import os

#                                                                                                                       
#  	Blockchain API Object
#

class BlockchainComDataAPI:

    ### Functions to initialise the object

    def __init__(self, verbose=False):
        self.api_config = self.__read_api_config()
        self.verbose = verbose
        self.__banner()


    def __str__(self):
        return f"{str(self.api_config)}"
    

    def __banner(self):
        if self.verbose:
            print (Fore.CYAN+ "BlockChain.Com API object created" + Style.RESET_ALL)
    

    ### Internal Functions

    def __read_api_config(self):
        try:
            _module_path = os.path.dirname(os.path.abspath(__file__))
            _filepath=_module_path + "/blockchain-api-config.json"
            with open(_filepath, 'r') as _file:
                _json_data = json.load(_file)
            return _json_data
        except FileNotFoundError:
            print(f"{Fore.RED}File {_filepath} not found.{Style.RESET_ALL}")


    def __encode_url (self, endpoint, replace_value, output_format='json'):

        # Replaces the requested token into the URL, also adding domain name and output format
        _route = self.api_config['endpoints'][endpoint]['route']
        _format = "/?format=" + output_format
        _base_url = self.api_config['api-info']['base-url']
        _replace_token = self.api_config['endpoints'][endpoint]['variable']

        _url = (_base_url + _route + _format).replace(_replace_token, str(replace_value))
        return _url
    

    def __fetch_from_api (self, url):

        if self.verbose:
            print (Fore.CYAN + "Accessing API... " + Style.RESET_ALL, end=" ")
        try:
            _result = requests.get(url=url)

            if (_result.status_code == 200):
                if self.verbose:
                    print (Fore.GREEN + "OK" + Style.RESET_ALL)
                return json.loads(_result.content)
            else:
                if self.verbose:
                    print (Fore.RED)
                    print (f"{url} failed with {_result.status_code}" + Style.RESET_ALL)
                return ({'status': 'data not retrieved'})
        except:
            if self.verbose:
                print (Fore.RED + "Failed" + Style.RESET_ALL)
            return ({'status': 'API failure'})


    ### Public Method Functions

    # API Access

    def api_info(self, format='json'):

        if (format == 'text'):
            return json.dumps(self.api_config['api-info'], indent=4)
        else:
            return self.api_config['api-info']


    def api_endpoints(self, format='json'):

        if (format == 'text'):
            return json.dumps(self.api_config['endpoints'], indent=4)
        else:
            return self.api_config['endpoints']


    def single_block (self, block_hash, output_format='json'):
        _endp = 'single-block'
        _uri = self.__encode_url (_endp, block_hash, output_format)
        return self.__fetch_from_api (_uri)


    def single_transaction (self, tx_hash, output_format='json'):
        _endp = 'single-transaction'
        _uri = self.__encode_url (_endp, tx_hash, output_format)
        return self.__fetch_from_api (_uri)


    def chart_data (self, chart_type, output_format='json'):
        _endp = 'chart-data'
        _uri = self.__encode_url (_endp, chart_type, output_format)
        return self.__fetch_from_api (_uri)


    def block_height (self, block_height, output_format='json'):
        _endp = 'block-height'
        _uri = self.__encode_url (_endp, block_height, output_format)
        return self.__fetch_from_api (_uri)


    def single_address (self, tx_hash, output_format='json'):
        _endp = 'single-address'
        _uri = self.__encode_url (_endp, tx_hash, output_format)
        return self.__fetch_from_api (_uri)


    def multi_address (self, addresses, output_format='json'):
        _endp = 'multi-address'
        _uri = self.__encode_url (_endp, addresses, output_format)
        return self.__fetch_from_api (_uri)


    def unspent_outputs (self, address, output_format='json'):
        _endp = 'unspent-outputs'
        _uri = self.__encode_url (_endp, address, output_format)
        return self.__fetch_from_api (_uri)


    def balance (self, address, output_format='json'):
        _endp = 'balance'
        _uri = self.__encode_url (_endp, address, output_format)
        return self.__fetch_from_api (_uri)


    def latest_block (self, output_format='json'):
        _endp = 'latest-block'
        _uri = self.__encode_url (_endp, 'null', output_format)
        return self.__fetch_from_api (_uri)


    def unconfirmed_transactions (self, output_format='json'):
        _endp = 'unconfirmed-transactions'
        _uri = self.__encode_url (_endp, 'null', output_format)
        return self.__fetch_from_api (_uri)


    def blocks_by_time (self, time_in_milliseconds, output_format='json'):
        _endp = 'blocks-by-time'
        _uri = self.__encode_url (_endp, time_in_milliseconds, output_format)
        return self.__fetch_from_api (_uri)


    def blocks_by_pool (self, pool_name, output_format='json'):
        _endp = 'blocks-by-pool'
        _uri = self.__encode_url (_endp, pool_name, output_format)
        return self.__fetch_from_api (_uri)

