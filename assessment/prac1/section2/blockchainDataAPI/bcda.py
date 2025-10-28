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


    def __encode_url (self, endpoint, replace_value, output_format='json', optional_param=''):

        # Replaces the requested token into the URL, also adding domain name and output format
        _route = self.api_config['endpoints'][endpoint]['route']
        if '?' in _route:
            _format = "&format=" + output_format
        else:
            _format = "?format=" + output_format
        _base_url = self.api_config['api-info']['base-url']
        _replace_token = self.api_config['endpoints'][endpoint]['variable']
        if self.verbose:
            print ("Swapping: ", _replace_token, replace_value)

        _url = (_base_url + _route + _format).replace(_replace_token, str(replace_value))
        if optional_param:
            _url = _url + "&" + optional_param
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
                status = 'data not retrieved (code:' + _result.status_code
                return ({'status': status})
        except:
            if self.verbose:
                print (Fore.RED + "Failed" + Style.RESET_ALL)
            return ({'status': 'API failure'})


    # Turn a list into chunks
    # This is needed to avoid rate limiting restrictions
    def __chunk_list(self, the_list, size=50):
        return [the_list[i:i + size] for i in range(0, len(the_list), size)]

    # Join a list together into a string using the pipe as a separator
    # This is needed for passing to the 'multiple' endpoints
    def __join_with_pipe (self, the_list):
        return  "|".join(map(str, the_list))


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


    def single_transaction (self, tx_hash, offset=0, output_format='json'):
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


    def single_address (self, bitcoin_address, output_format='json', offset=0):
        _endp = 'single-address'
        _uri = self.__encode_url (_endp, bitcoin_address, output_format, optional_param="offset=" + str(offset))
        return self.__fetch_from_api (_uri)


    def multi_address (self, addresses, output_format='json'):
        _endp = 'multi-address'

        _return_json = {}

        # If we have more than 1 address, chunk them in fifties
        if len(addresses) > 1:
            _chunked_addresses = self.__chunk_list (addresses)
            for _chunk in _chunked_addresses:
                _address_string = self.__join_with_pipe(_chunk)
                _uri = self.__encode_url (_endp, _address_string, output_format)
                _response = self.__fetch_from_api (_uri)
                if 'status' not in _response:
                    _return_json.update(_response)
            return _return_json

        # If we have a single address, just ask for it
        else:
            _uri = self.__encode_url (_endp, addresses, output_format)
            return self.__fetch_from_api (_uri)


    def unspent_outputs (self, address, output_format='json'):
        _endp = 'unspent-outputs'
        _uri = self.__encode_url (_endp, address, output_format)
        return self.__fetch_from_api (_uri)


    def balance (self, address, output_format='json'):
        _endp = 'balance'

        _return_json = {}

        # If we have more than 1 address, chunk them in fifties
        if len(address) > 1:
            _chunked_addresses = self.__chunk_list (address)
            for _chunk in _chunked_addresses:
                _address_string = self.__join_with_pipe(_chunk)
                _uri = self.__encode_url (_endp, _address_string, output_format)
                _response = self.__fetch_from_api (_uri)
                if 'status' not in _response:
                    _return_json.update(_response) 
            return _return_json

        else:
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
    
    
    def exchange_rate (self, symbol):
        _uri = 'https://blockchain.info/ticker'
        _json_data = self.__fetch_from_api (_uri)
        if symbol in _json_data.keys():
            return _json_data[symbol]['last']



