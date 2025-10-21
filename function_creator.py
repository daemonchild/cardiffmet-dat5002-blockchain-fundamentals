# Create functions from JSON :)
def genFuncFromTemplate ():

    _template = """
    def getFunctionName (var_value, output_format='json'):

        _endp = 'Title'
        _uri = self.__encode_url (_endp, var_value, output_format)
        return self.__fetch_from_api (_uri)"""

    for _ep in endpoints.keys():

        _my_func = _template
        _my_func = _my_func.replace('var_value', endpoints[_ep]['variable'])
        _my_func = _my_func.replace('Title', _ep)
        _my_func = _my_func.replace('FunctionName', _ep.replace('-',''))
        _my_func = _my_func.replace ('$','')
        
        print (_my_func)