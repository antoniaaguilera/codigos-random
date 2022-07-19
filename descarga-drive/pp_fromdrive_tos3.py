import gdown
import os
from os import listdir
import pandas as pd
import boto3

# --------------------------------------------------------------- #
# ------------------------ PREAMBULO ---------------------------- #
# --------------------------------------------------------------- #

os.chdir("/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/random_data/fotos-pridepoints")

s3 = boto3.client('s3')

pp = pd.read_csv("/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/inputs/Pridepoints/pridepoints_hasta57_tablaimagespridepoints.csv")
list(pp)

# ------------------------------------------------- #
# ------------------- CLEAN ----------------------- #
# ------------------------------------------------- #
# reemplazar "open" por "uc" en todos los links
pp['link'] = pp['link'].replace({'open':'uc'})
pp['link'] = pp['link'].str.replace('open','uc')
pp = pp.sort_values(by=['campus_code', 'pridepoint_label_id', 'image_order'])
pp = pp.reset_index(drop=True)

#iterar por todos los rbd que están en la base
pp_rbd = pp.drop_duplicates(subset=['campus_code'])
pp_rbd = pp_rbd['campus_code']
pp_rbd = pp_rbd.reset_index(drop=True)

new_links = pd.DataFrame()
new_links = pd.DataFrame(columns=['campus_code', 'institution_code', 'pridepoint_label_id', 'image_order', 'link_2'])

# ------------------------------------------------ #
# ------------ DOWNLOAD AND UPLOAD --------------- #
# ------------------------------------------------ #
#
for school in range(0,len(pp_rbd)):
    #subset pp
    pp_mini = pp[pp['campus_code'] == pp_rbd[school]]
    pp_mini = pp_mini.reset_index(drop=True)

    rbd = pp_mini['institution_code'][0]
    campus_code = pp_mini['campus_code'][0]
    os.makedirs(f'./{rbd}', exist_ok = True)

    #DOWNLOAD
    for x in range(0,len(pp_mini)):
        #setear variables
        url     = pp_mini['link'][x]
        labelid = pp_mini['pridepoint_label_id'][x]
        order   = pp_mini['image_order'][x]
        #nombre del archivo: pp_rbd_labelid_order.png
        output = f'./{rbd}/pp_{rbd}_labelid{labelid}_order{order}.png'
        #gdown.download(url, output, quiet=False)

        file_name = f'pp_{rbd}_labelid{labelid}_order{order}.png'
        #UPLOAD
        #s3.upload_file(
        #    Filename=f'./{rbd}/{file_name}',
        #	Bucket='cb-explorer-chile',
        #    Key=f'schools/{rbd}/images-pridepoints/{file_name}',
        #    ExtraArgs={'ACL':'public-read'}
        #)
        link = f'https://cb-explorer-chile.s3.amazonaws.com/schools/{rbd}/images-pridepoints/{file_name}'
        new_links = new_links.append({'campus_code': campus_code, 'institution_code':rbd, 'pridepoint_label_id': labelid, 'image_order': order, 'link_2':link}, ignore_index=True)

aux=pp.merge(new_links, how='left')
aux
aux['link_2'][0]
list(aux)

aux.to_csv("/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/inputs/Pridepoints/pridepoint_images_s3.csv")
