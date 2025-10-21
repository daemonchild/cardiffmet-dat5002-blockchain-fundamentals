#  __  _____   ____   ___ ____  ___    ____ ____  _ _____           _____                    __                          
# / _\/__   \ |___ \ / _ \___ \( _ )  | ___|___ \/ |___ /          /__   \___  _ __ ___     /__\ _____      ____ _ _ __  
# \ \   / /\/   __) | | | |__) / _ \  |___ \ __) | | |_ \   _____    / /\/ _ \| '_ ` _ \   / \/// _ \ \ /\ / / _` | '_ \ 
# _\ \ / /     / __/| |_| / __/ (_) |  ___) / __/| |___) | |_____|  / / | (_) | | | | | | / _  \ (_) \ V  V / (_| | | | |
# \__/ \/     |_____|\___/_____\___/  |____/_____|_|____/           \/   \___/|_| |_| |_| \/ \_/\___/ \_/\_/ \__,_|_| |_|
#
#  	Title:		            Blockchain.Com Data API (BCDA) - Address
# 
import requests
import json
import time
import os
from datetime import datetime
from colorama import Fore, Back, Style

# Load local utilities
from . import bcda
from . import block_chain_miners as bcm

class Address:

    ### Functions to initialise the object

    def __init__(self, addr):
        self.__banner()
        if (len(hash) == 64):
            # Fetch the data from the BC API
            _bc = bcda.BlockchainComDataAPI()
            self.json = _bc.single_address(addr)
            self.mining_pool_data=bcm.load_mining_pool_data()
            print (Fore.GREEN + "initialised" + Style.RESET_ALL)
        else:
            self.json = {}
            print (Fore.RED + "failed to initialise using supplied hash!" + Style.RESET_ALL)

    def __str__(self):
        return json.dumps(self.json, indent=4)
    
    def __banner(self):

        print (Fore.CYAN + "Address object" + Style.RESET_ALL, end=" " )
    
