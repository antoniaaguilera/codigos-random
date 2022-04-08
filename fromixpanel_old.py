import os
import pandas as pd
import numpy as np
from mixpanel_utils import MixpanelUtils
from datetime import date, datetime, timedelta
import logging
import boto3

# --------------------------------------------------- #
# -------------------- PREAMBLE --------------------- #
# --------------------------------------------------- #

# paths
os.chdir('/Users/antoniaaguilera/ConsiliumBots Dropbox/ConsiliumBots/Projects/Chile/Explorador/Data/mixpanel_analysis_2022/mixpanel_dump')

# dates
yesterday = date.today() - timedelta(days =1)
start_date = yesterday
end_date = yesterday
download_date = f"{yesterday.year}-{yesterday.month}-{yesterday.day}"
yesterday
# make monthly directory if downloaded data is the first of the month
if yesterday.day == 1:
	os.mkdir(f"./{yesterday.year}-{yesterday.month}")

# time_offsetx
timezone = 0
#CREO que con eso se descarga en GTM-3 que es la hora Chile al 10-marzo
#sabado 2 de abril cambiaa GMT-4 creo

#path where data is going to be stored
save_path = f"./{yesterday.year}-{yesterday.month}/events_from{download_date}_to{download_date}.csv"

# --------------------------------------------------- #
# --------------- CALL MIXPANEL DATA ---------------- #
# --------------------------------------------------- #

if __name__ == '__main__':
	credentials = {
		'API_secret': '442dfdb19c05c3664718174271e96cdf',
		'token': '54a0868c0a0ad44ca6742f3ad6ddcf7f'
	}

	m = MixpanelUtils(credentials['API_secret'])
	m.export_events(save_path,{'from_date':start_date,'to_date':end_date},timezone_offset = timezone, format='csv')

# --------------------------------------------------------- #
# --------------- APPEND WITH PREVIOUS DAY ---------------- #
# --------------------------------------------------------- #
df = pd.read_csv(f"./{yesterday.year}-{yesterday.month}/events_from{download_date}_to{download_date}.csv")
# --- format date
df['time'] = pd.to_datetime(df['time'], unit='s')
df['date'] = df['time'].dt.date
# --- keep only production environment
df = df[(df['env']=='PRODUCTION')| (df['env']=='master')]

# --- if it's the first of the month, keep and save
# --- if it's the
if yesterday.day == 1:
	df.to_csv(f"./{yesterday.year}-{yesterday.month}/events_from{download_date}_to{download_date}.csv")
else :
	before_yesterday = yesterday - timedelta(days = 1)
	before_yesterday_date = f"{before_yesterday.year}-{before_yesterday.month}-{before_yesterday.day}"
	last_saved = pd.read_csv(f"./{yesterday.year}-{yesterday.month}/events_from{yesterday.year}-{yesterday.month}-1_to{before_yesterday_date}.csv")
	current = last_saved.append(df)
	current.to_csv(f"./{yesterday.year}-{yesterday.month}/events_from{yesterday.year}-{yesterday.month}-1_to{download_date}.csv")
	os.remove(f"./{yesterday.year}-{yesterday.month}/events_from{yesterday.year}-{yesterday.month}-1_to{before_yesterday_date}.csv")
	os.remove(f"./{yesterday.year}-{yesterday.month}/events_from{download_date}_to{download_date}.csv")


#revisar pegue con rbds
#subir a s3 día a día
#borrar data dropbox

# --------------------------------------------------------- #
# --------------------- UPLOAD TO S3 ---------------------- #
# --------------------------------------------------------- #

s3_connection = boto.connect_s3()
bucket = s3_connection.get_bucket('your bucket name')
key = boto.s3.key.Key(bucket, 'some_file.zip')
with open('some_file.zip') as f:
    key.send_file(f)
