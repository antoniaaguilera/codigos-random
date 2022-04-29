/*
================================================================================
FECHA CREACION: 2022-04-19
ULTIMA MODIFICACION: 2022-04-19 // ijacas
--------------------------------------------------------------------------------
PROYECTO: Tether
================================================================================
*/

clear all
set more off

// Nombre de usuario
display "`c(username)'"

if "`c(username)'"=="ij1376" { // Isa
    global pathData =  "C:/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
    global pathRandom = "C:/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/data/"
}



// COLEGIOS QUE FUERON MENCIONADOS EN LAS MISMAS POSTULACIONES

// COLEGIOS A 2 KM


* ============================================================= *
* ============================================================= *
* ======================== FROM BACK ========================== *
* ============================================================= *
* ============================================================= *

/*
Vamos a obtener del back:
- Que colegios tienen perfil digital
- Cuáles son los colegios de Quinta Normal que participan del SAE
- Qué precio tienen
- Cuántos clicks a perfil y map card tienen

*/


import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_audiovisual.csv", clear charset(utf8)

tab audiovisual_label_id
keep if audiovisual_label_id<=6
gen sobrevuelo = audiovisual_label_id == 1
gen dron = audiovisual_label_id == 2
gen testimonios = audiovisual_label_id > 2

keep campus_code institution_code sobrevuelo dron testimonios

collapse (max) sobrevuelo dron testimonios, by(campus_code institution_code)

gen perfildigital = sobrevuelo == 1 | dron == 1 | testimonios == 1
tempfile videos
save `videos'



import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_location.csv", clear charset(utf8)
keep if plocation_id == 351
tempfile qn_schools
save `qn_schools'


import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_payment.csv", clear charset(utf8)
drop year
duplicates tag campus_code, gen(dup)
drop if dup>0 & _n>=17174
drop dup
tempfile payment
save `payment'

import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_explored_profile.csv", clear charset(utf8)
gen clicks_profile = 1
collapse (sum) clicks, by(campus_code)
tempfile expprofile
save `expprofile'

import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_explored_card.csv", clear charset(utf8)
gen clicks_card = 1
collapse (sum) clicks, by(campus_code)
tempfile expcard
save `expcard'


import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_campus.csv", clear charset(utf8)
merge 1:1 campus_code using `qn_schools', keep(3) nogen
merge 1:1 campus_code using `payment', keep(3) nogen
merge 1:1 campus_code using `expprofile', keep(3) nogen
merge 1:1 campus_code using `expcard', keep(3) nogen
merge 1:1 campus_code using `videos', keep(1 3) nogen
replace perfildigital = 0 if perfildigital == .

collapse (mean) payment_category_label_id sector_id (sum) clicks_profile clicks_card (max) perfildigital, by(institution_code)
rename institution_code rbd

tempfile rbds_quinta
save `rbds_quinta'


* ============================================================= *
* ============================================================= *
* ======================== SAE 2021-2022 ====================== *
* ============================================================= *
* ============================================================= *

/*
Vamos a obtener de SAE 2021-2022:
- Vacantes de cada Colegio de Quinta Normal
- Postulaciones de cada Colegio de Quinta Normal
- Distribución de Número de Colegios en la Postulación de niños en QN
*/
import delimited "$pathData/inputs/2022_04_05/SAE_2021/A1_Oferta_Establecimientos_etapa_regular_2021_Admisión_2022.csv", clear charset(utf8)
collapse (sum) cupos_totales vacantes, by(rbd)
tempfile vacantes
save `vacantes'


import delimited "$pathData/inputs/2022_04_05/SAE_2021/D1_Resultados_etapa_regular_2021_Admisión_2022_PUBL.csv", clear charset(utf8)
gen asignados = 1
replace rbd_admitido = rbd_admitido_post_resp if rbd_admitido == " "
drop if rbd_admitido == " "

collapse (sum) asignados, by(rbd_admitido)
destring rbd_admitido, replace
rename rbd_admitido rbd

merge 1:1 rbd using `vacantes'
replace asignados = 0 if asignados == .
drop _merge
tempfile vacantes
save `vacantes'




import delimited "$pathData/inputs/2022_04_05/SAE_2021/C1_Postulaciones_etapa_regular_2021_Admisión_2022_PUBL.csv", clear charset(utf8)
merge m:1 rbd using `rbds_quinta', keep(3) nogen
tab cod_nivel if rbd == 26352
drop if cod_nivel >8

preserve
gen postulantes = 1
// keep if cod_nivel==-1
collapse (sum) postulantes, by(rbd)
tempfile postulantes
save `postulantes'

merge 1:1 rbd using `vacantes', keep(3) nogen
merge 1:1 rbd using `rbds_quinta', keep(1 3) nogen
gen cupos_remanentes = vacantes - asignados
replace cupos_remanentes = 0 if cupos_remanentes<0


keep if payment_category_label_id == 1
sort rbd

// export delimited "$pathRandom/para_andrea/colegio_26352_prek.csv", replace
export delimited "$pathRandom/bases andrea_marcy/colegio_26352.csv", replace
restore

keep mrun
duplicates drop mrun, force
tempfile post_qn
save `post_qn'


import delimited "$pathData/inputs/2022_04_05/SAE_2021/C1_Postulaciones_etapa_regular_2021_Admisión_2022_PUBL.csv", clear charset(utf8)
merge m:1 mrun using `post_qn', keep(3) nogen
bysort mrun: egen maxord = max(preferencia_postulante)
collapse (mean) maxord, by(mrun)

sum maxord, detail
dis _N
export delimited "$pathRandom/bases andrea_marcy/postulantes_quintaNormal.csv", replace
