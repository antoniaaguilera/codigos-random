/*
================================================================================
FECHA CREACION: 2022-05-27
ULTIMA MODIFICACION: 2022-05-27 // ijacas
--------------------------------------------------------------------------------
PROYECTO: Tether y Exploradores - Chile
================================================================================

Este código crea un directorio de sostenedores con su información de contacto.

*/

clear all
set more off


* ============================================================= *
* ========================== PREÁMBULO ======================== *
* ============================================================= *

// Nombre de usuario
display "`c(username)'"

// Paths
  if "`c(username)'"=="ijacas" { // Isa
    global pathData =  "C:/Users/ijacas/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
    global pathDataRandom =  "C:/Users/ijacas/ConsiliumBots Dropbox/Isabel Jacas/data/"
    global pathGit =  "C:/Users/ijacas/Desktop/GitHub/Exploradores/Chile/E_Escolar/"
  }

global date_sostenedores = "2022_05_25"



import excel "$pathData/inputs/$date_sostenedores/REX-Nº-0366-ACTUALIZA-REGISTRO-DE-CORREOS-ELECTRÓNICOS-DE-SOSTENEDORES-AÑO-2020 (1).xlsx", clear cellrange(A12:L5008) firstrow
drop if RutSostenedor == "Rut Sostenedor"
rename (RutSostenedor NombreSostenedor Correoelectrónicosostenedor) (rut nombre contacto)
keep rut nombre contacto
split rut, p("-")
drop rut2 rut
rename rut1 rut
tempfile contacto
save `contacto'

import delimited "$pathData/inputs/$date_sostenedores/Directorio_Oficial_Sostenedores_2021.csv", clear charset(utf8) delimiter(";")
dis _N
keep rut_sost mrun p_juridica nombre_sost num_rb* mat* num_c* rbd_*
tab p_juridica
rename rut_sost rut
merge m:1 rut using `contacto'
drop if _merge == 2

count if num_rbd_mun_daem>0 & num_rbd_part_subv>0
count if num_rbd_mun_daem>0 & num_rbd_adm_del>0
count if num_rbd_mun_daem>0 & num_rbd_serv_loc>0
count if num_rbd_part_subv>0 & num_rbd_adm_del>0
count if num_rbd_part_subv>0 & num_rbd_serv_loc>0
count if num_rbd_mun_daem>0 & num_rbd_corp_mun>0


drop nombre _merge


keep contacto rut mrun p_juridica nombre_sost rbd*

forvalues i = 1/9 {
  rename rbd_00`i' rbd_`i'
}

forvalues i = 10/99 {
  rename rbd_0`i' rbd_`i'
}

destring, replace
reshape long rbd_, i(contacto rut mrun p_juridica nombre_sost) j(num_rbd)
drop if rbd_==.
rename rbd_ rbd

preserve
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_institutions.csv", clear charset(utf8)
keep institution_code institution_name
rename institution_code rbd
tempfile namesrbd
save `namesrbd'
restore

merge 1:1 rbd using `namesrbd'
keep if _merge >1 // Nos quedamos solo con los colegios que están en el explorador.
drop _merge

order rut mrun p_juridica nombre_sost
drop num_rbd

export delimited "$pathDataRandom/base_sostenedores.csv", replace
