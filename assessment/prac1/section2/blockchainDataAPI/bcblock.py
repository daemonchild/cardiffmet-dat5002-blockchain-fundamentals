#  __  _____   ____   ___ ____  ___    ____ ____  _ _____           _____                    __                          
# / _\/__   \ |___ \ / _ \___ \( _ )  | ___|___ \/ |___ /          /__   \___  _ __ ___     /__\ _____      ____ _ _ __  
# \ \   / /\/   __) | | | |__) / _ \  |___ \ __) | | |_ \   _____    / /\/ _ \| '_ ` _ \   / \/// _ \ \ /\ / / _` | '_ \ 
# _\ \ / /     / __/| |_| / __/ (_) |  ___) / __/| |___) | |_____|  / / | (_) | | | | | | / _  \ (_) \ V  V / (_| | | | |
# \__/ \/     |_____|\___/_____\___/  |____/_____|_|____/           \/   \___/|_| |_| |_| \/ \_/\___/ \_/\_/ \__,_|_| |_|
#
# Block Chain Block Object
#

import json
from datetime import datetime
from colorama import Fore, Style

# Load local utilities from the module
from . import bcda
from . import block_chain_miners as bcm

class Block:

    ### Functions to initialise the object

    # Init Constructor
    def __init__(self, hash, verbose=False):

        # Is debug mode enabled?
        self.verbose = verbose
        self.__banner()

        # Is it a valid hash?
        if (len(hash) == 64 and hash.startswith('0')):

            # Fetch the data from the BC API
            _bc = bcda.BlockchainComDataAPI(verbose=self.verbose)
            _result = _bc.single_block(hash)

            # Check for valid results
            if 'status' not in _result:
                self.json = _result
                if self.verbose:
                    print (Fore.GREEN + "initialised" + Style.RESET_ALL)
            else:
                self.json = {}
                print (Fore.RED + "Failed to initialise: API failure" + Style.RESET_ALL)
    
        else:
            self.json = {}
            print (Fore.RED + "Failed to initialise using supplied hash!" + Style.RESET_ALL)

    # Return a printable string version of the block
    def __str__(self):
        return json.dumps(self.json, indent=4)
    
    def __banner(self):
        if self.verbose:
            print (Fore.CYAN + "Block object " + Style.RESET_ALL, end=" " )
    
    ### Functions

    # Return the entire block as a json object
    def as_json(self):
        return self.json

    # Calculate the time, date etc in various formats
    def time(self):
        _timestamp = self.json['time']
        _datetime = datetime.fromtimestamp(_timestamp)
        _mined_at = _datetime.strftime("%H:%M")
        return _mined_at
    
    def date(self):
        _timestamp = self.json['time']
        _datetime = datetime.fromtimestamp(_timestamp)
        _mined_at = _datetime.strftime("%d/%m/%Y")
        return _mined_at
    
    def mined_at(self):
        _timestamp = self.json['time']
        _datetime = datetime.fromtimestamp(_timestamp)
        _mined_at = _datetime.strftime("%d/%m/%Y %H:%M")
        return _mined_at
    
    def timestamp(self):
        return self.json['time']
    
    def datetime(self):
        _timestamp = self.json['time']
        _datetime = datetime.fromtimestamp(_timestamp)
        return _datetime
    
    # Return the hash of the miner of the block (and name, if known)
    def mined_by(self):
        # Search the first transaction to find the miner
        _coinbase_tx = self.json['tx'][0]
        for _output in _coinbase_tx.get('out', []):
            _addr = _output.get('addr')
            _value = _output.get('value', 0)

            if _addr and _value > 0:

                # Try to use the mining pool data to find a name for the miner
                # Load mining pool data
                _mining_pool_data=bcm.load_mining_pool_data()
                _miner = bcm.search_miner_address(_addr, _mining_pool_data['mining_pools'])
                return (_miner + " [" + _addr + "]" )
            else:
                return " Error: No addresses in coinbase transaction."
    
    # Calculate the difficulty of the block
    def difficulty (self):
        
        # Reference: https://wiki.bitcoinsv.io/index.php/Target
        # Reference: https://bitcoin.stackexchange.com/questions/30467/what-are-the-equations-to-convert-between-bits-and-difficulty

        _exponent = self.json['bits'] >> 24
        _mantissa = self.json['bits'] & 0xffffff
        _target = _mantissa * (1 << (8 * (_exponent - 3)))
        
        # Difficulty of block 1 target (constant)
        _diff_orig_target = 0x00000000FFFF0000000000000000000000000000000000000000000000000000
        _diff = _diff_orig_target / _target
        return _diff
    
    # Return the number of leading zeroes in the block hash
    # An indication of difficulty
    def leading_zeroes(self):
        _leading_zeroes = len(self.hash()) - len(self.hash().lstrip('0'))
        return _leading_zeroes
    
    # Return a list of addresses from the transactions in the block
    def output_addresses (self):

        _addresses = []

        # Run through the list of transactions in the block
        for _tx in self.json['tx']:
            _outputs = _tx['out']

            for _o in _outputs:
                if 'addr' in _o.keys():
                    _addr = _o['addr']
                    _addresses.append(_addr)

        # Deduplicate by casting to a set and then back to a list
        _addresses = list(set(_addresses))
        return _addresses

    # Truncated hash for printing
    def trunc_hash(self):
        return self.json['hash'][:4] + "..." + self.json['hash'][-4:]
    
    # Functions to return various parameters from the block without processing
    def hash(self):
        return self.json['hash']
    
    def prev_block_hash(self):
        return self.json['prev_block']

    def height(self):
        return self.json['height']
    
    def weight(self):
        return self.json['weight']
    
    def size(self):
        return self.json['size']
    
    def number_tx(self):
        return self.json['n_tx']
    
    def tx(self):
        return self.json['tx']