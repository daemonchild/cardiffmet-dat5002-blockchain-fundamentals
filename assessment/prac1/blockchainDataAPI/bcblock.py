#  __  _____   ____   ___ ____  ___    ____ ____  _ _____           _____                    __                          
# / _\/__   \ |___ \ / _ \___ \( _ )  | ___|___ \/ |___ /          /__   \___  _ __ ___     /__\ _____      ____ _ _ __  
# \ \   / /\/   __) | | | |__) / _ \  |___ \ __) | | |_ \   _____    / /\/ _ \| '_ ` _ \   / \/// _ \ \ /\ / / _` | '_ \ 
# _\ \ / /     / __/| |_| / __/ (_) |  ___) / __/| |___) | |_____|  / / | (_) | | | | | | / _  \ (_) \ V  V / (_| | | | |
# \__/ \/     |_____|\___/_____\___/  |____/_____|_|____/           \/   \___/|_| |_| |_| \/ \_/\___/ \_/\_/ \__,_|_| |_|

import requests
import json
import time
import os
from datetime import datetime
from colorama import Fore, Back, Style

# Load local utilities
from . import bcda
from . import block_chain_miners as bcm


class Block:

    ### Functions to initialise the object

    def __init__(self, hash):
        self.__banner()
        if (len(hash) == 64):
            # Fetch the data from the BC API
            _bc = bcda.BlockchainComDataAPI()
            self.json = _bc.single_block(hash)
            self.mining_pool_data=bcm.load_mining_pool_data()
            print (Fore.GREEN + "initialised" + Style.RESET_ALL)
        else:
            self.json = {}
            print (Fore.RED + "failed to initialise using supplied hash!" + Style.RESET_ALL)

    def __str__(self):
        return json.dumps(self.json, indent=4)
    
    def __banner(self):

        print (Fore.CYAN + "Block object" + Style.RESET_ALL, end=" " )
    

    ### Functions

    def as_json(self):
        return self.json

    def time(self):
        _timestamp = self.json['time']
        _datetime = datetime.fromtimestamp(_timestamp)
        _mined_at = _datetime.strftime("%d/%m/%Y %H:%M")
        return _mined_at

    def hash(self):
        return self.json['hash']
    
    def prev_block_hash(self):
        return self.json['prev_block']

    def height(self):
        return self.json['height']
    
    def number_tx(self):
        # or len(self.json[tx]) would also work
        return self.json['n_tx']
    
    def tx(self):
        return self.json['tx']
    
    def mined_by(self):

        # Search the first transaction to find the miner
        _coinbase_tx = self.json['tx'][0]
        for _output in _coinbase_tx.get('out', []):
            _addr = _output.get('addr')
            _value = _output.get('value', 0)

            if _addr and _value > 0:

                # Try to use the mining pool data to find a name for the miner
    
                _miner = bcm.search_miner_address(_addr, self.mining_pool_data)
                return (_miner + " [" + _addr + "]" )
            else:
                return "No addresses in coinbase transaction."
    
    def difficulty (self):
        _diff =  (Fore.YELLOW + "[Warning - Not Implemented]" + Style.RESET_ALL)
        return _diff
    
    def leading_zeroes(self):
        _leading_zeroes = len(self.hash()) - len(self.hash().lstrip('0'))
        return _leading_zeroes
        

