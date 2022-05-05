import pandas as pd
import numpy as np

pathData = "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/random_data/coords_to_latlons/"
pathSave =

df = pd.read_excel(f"{pathData}/Thumbnails.xlsx", sheet_name='Vitacura', header=1)

df['Coordenadas'] = df['Coordenadas'].str.replace(" ","")
df['Coordenadas'] = df['Coordenadas'].str.replace(",",".")
df['lon'] = df['Coordenadas'].str.extract('S(.*)')
df['lon_len'] = df['lon'].str.len()
df['tot_len'] = df['Coordenadas'].str.len()
df['lat_len'] = df['tot_len']-df['lon_len']
df['lat_len'] = df['lat_len'].replace([np.NaN],0)
for x in range(max(df.index)):
    len = int(df['lat_len'][x])
    aux = str(df['Coordenadas'].iloc[x])
    df.loc[x,'lat'] = aux[:len]

#formula
def conversion(old):
    direction = {'N':1, 'S':-1, 'E': 1, 'W':-1}
    new = old.replace(u'°',' ').replace('\'',' ').replace('"',' ')
    new = new.split()
    new_dir = new.pop()
    new.extend([0,0,0])
    return ((float(new[0])+float(new[1])/60+float(new[2])/3600) * direction[new_dir])
#correr formula de conversión
for x in range(max(df.index)):
    latitud = df.loc[x,'lat']
    longitud = df.loc[x,'lon']
    if latitud!='':
        lat, lon = f"{latitud}, {longitud}".split(', ')
        df.loc[x,'new_lat'] = conversion(lat)
        df.loc[x,'new_lon'] = conversion(lon)
list(df)
df = df[['RBD', 'new_lat', 'new_lon']]
df.rename(columns={"RBD": "institution_code", "lat": "lon"})

df.to_excel(f"{pathSave}/motohunter_hoja1.xlsx")
