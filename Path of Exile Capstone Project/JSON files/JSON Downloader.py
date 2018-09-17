# -*- coding: utf-8 -*-
"""
Created on Fri Aug 31 08:38:58 2018

@author: LLDS
"""

import schedule 
import time
import urllib.request
import datetime

def download_file():
    urllib.request.urlretrieve("http://api.pathofexile.com/public-stash-tabs", filename = datetime.datetime.now().strftime("%m_%d, %H_%M") + ".json")
    
schedule.every(30).minutes.do(download_file)

while True:
    schedule.run_pending()
    time.sleep(1)
    