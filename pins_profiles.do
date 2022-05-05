/*
================================================================================
FECHA CREACION: 2022-04-21
ULTIMA MODIFICACION: 2022-04-21 // ijacas
--------------------------------------------------------------------------------
PROYECTO: Exploradores - Chile
================================================================================

Este código crea bases para figuras de matlab para mostrar la diferencia en pins
y profiles para colegios con y sin video.

*/

clear all
set more off


* ============================================================= *
* ========================== PREÁMBULO ======================== *
* ============================================================= *

// Nombre de usuario
display "`c(username)'"

// Paths
  if "`c(username)'"=="ij1376" { // Isa Princeton
    global pathData =  "C:/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
    global pathDataRandom =  "C:/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/data/"
    global pathGit =  "C:/Users/ij1376/GitHub/Exploradores/Chile/E_Escolar/"
  }


* ============================================================= *
* ================ INSTITUTIONS CON VIDEO ===================== *
* ============================================================= *

import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_audiovisual.csv", clear charset(utf8)

tab audiovisual_label_id
keep if audiovisual_label_id<=6
gen sobrevuelo = audiovisual_label_id == 1
gen dron = audiovisual_label_id == 2
gen testimonios = audiovisual_label_id > 2

keep campus_code institution_code sobrevuelo dron testimonios

collapse (max) sobrevuelo dron testimonios, by(campus_code institution_code)

tempfile videos
save `videos'



* ============================================================= *
* ====================== PINS Y PROFILES  ===================== *
* ============================================================= *

import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_explored_card.csv", clear charset(utf8)

gen pins = 1
collapse (sum) pins, by(campus_code)

tempfile pins
save `pins'


import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_explored_profile.csv", clear charset(utf8)

gen profile = 1
collapse (sum) profile, by(campus_code)

tempfile profile
save `profile'


use `videos', clear
merge 1:1 campus_code using `pins'
foreach x in sobrevuelo dron testimonios pins {
  replace `x' = 0 if `x' == .
}
drop _merge

merge 1:1 campus_code using `profile'
foreach x in sobrevuelo dron testimonios pins profile {
  replace `x' = 0 if `x' == .
}
drop _merge

drop institution_code

gen perfildigital = sobrevuelo == 1 | dron == 1 | testimonios == 1

export delimited "$pathDataRandom/para_andrea/grafico_perfildigital.csv", replace
