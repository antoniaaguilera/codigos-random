
clear all
set more off

// Nombre de usuario
display "`c(username)'"


// Paths
  if "`c(username)'"=="ij1376" { // Isa Princeton
    global pathData =  "C:/Users/ij1376/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile/Output/"
    global pathDataSM =  "C:/Users/ij1376/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile/"
    global pathDataExp =  "C:/Users/ij1376/Dropbox/Exploradores/Explorador_Chile/E_Escolar/"
    global pathGit =  "C:/Users/ij1376/GitHub/SchoolingMarkets_Exp/Chile/4. Describe Markets/"
  }



import delimited "$pathData/Preview/DATA/supply_preview.csv", clear charset(utf8)

sort institution_code
replace type_prek = type_prek[_n+1] if institution_code == institution_code[_n+1] & type_prek[_n+1] !="" & institution_code !=.
replace type_prek = type_prek[_n-1] if institution_code == institution_code[_n-1] & type_prek[_n-1] !="" & institution_code !=.
drop origen db_origin

replace type = type_prek if type == "Preescolar"
replace type = "Particular Pagado" if type == "Particular"
replace type = "Particular Subvencionado" if type == "Subvencionado"
drop geo_provincia_name
collapse (sum)  matricula_preescolar matricula_primaria matricula_secundaria matricula_total (max) institution_code_prek latitud longitud  urban geo_region geo_provincia geo_comuna preescolar primaria secundaria, by(institution_code type type_prek school_name  geo_region_name geo_comuna_name)

replace preescolar = 0 if preescolar == .
duplicates report institution_code


gen stage = ""
replace stage = "Preescolar, Primaria y Secundaria" if preescolar == 1 & primaria == 1 & secundaria == 1
replace stage = "Preescolar y Secundaria" if preescolar == 1 & primaria == 0 & secundaria == 1
replace stage = "Preescolar y Primaria" if preescolar == 1 & primaria == 1 & secundaria == 0
replace stage = "Preescolar" if preescolar == 1 & primaria == 0 & secundaria == 0
replace stage = "Primaria y Secundaria" if preescolar == 0 & primaria == 1 & secundaria == 1
replace stage = "Primaria" if preescolar == 0 & primaria == 1 & secundaria == 0
replace stage = "Secundaria" if preescolar == 0 & primaria == 0 & secundaria == 1

order institution_code institution_code_prek school_name type geo_region_name geo_region geo_provincia geo_comuna_name geo_comuna  urban latitud longitud stage preescolar primaria secundaria matricula_preescolar matricula_primaria matricula_secundaria matricula_total


gen country = "Chile"
order country


preserve
import delimited "$pathDataExp/inputs/2022_02_22/Directorio_Extraordinario_EE_2022.csv", clear
rename rbd institution_code
keep institution_code pago_matricula pago_mensual
tempfile costos
save `costos'
restore

merge m:1 institution_code using `costos'
drop if _merge == 2
drop _merge

replace pago_matricula = "SIN INFORMACION" if pago_matricula == ""
replace pago_mensual = "SIN INFORMACION" if pago_mensual == ""


duplicates tag institution_code_prek, gen(dup)
sort institution_code_prek
drop dup

preserve
import delimited "$pathDataExp/outputs/update/2022_03_23/institutions_institutions.csv", clear charset(utf8)
keep institution_code grade_max grade_min
tempfile grades
save `grades'
restore

merge m:1 institution_code using `grades'
drop if _merge == 2
drop _merge
replace grade_max = "Sin Información" if grade_max == ""
replace grade_min = "Sin Información" if grade_min == ""

preserve
import delimited "$pathDataExp/outputs/upload/2022_02_03/institutions_qualitymeasure_categ.csv", clear
keep institution_code qualitymeasure_categ_label_id qualitycateglevel_id
gen cat_desempeno_basica = "Insuficiente" if qualitycateglevel_id == 1 & qualitymeasure_categ_label_id == 1
replace cat_desempeno_basica = "Medio-Bajo" if qualitycateglevel_id == 2 & qualitymeasure_categ_label_id == 1
replace cat_desempeno_basica = "Medio" if qualitycateglevel_id == 3 & qualitymeasure_categ_label_id == 1
replace cat_desempeno_basica = "Alto" if qualitycateglevel_id == 4 & qualitymeasure_categ_label_id == 1

gen cat_desempeno_media = "Insuficiente" if qualitycateglevel_id == 1 & qualitymeasure_categ_label_id == 2
replace cat_desempeno_media = "Medio-Bajo" if qualitycateglevel_id == 2 & qualitymeasure_categ_label_id == 2
replace cat_desempeno_media = "Medio" if qualitycateglevel_id == 3 & qualitymeasure_categ_label_id == 2
replace cat_desempeno_media = "Alto" if qualitycateglevel_id == 4 & qualitymeasure_categ_label_id == 2

collapse (firstnm) cat_desempeno_basica cat_desempeno_media, by(institution_code)
tempfile catdes
save `catdes'
restore


merge m:1 institution_code using `catdes'
drop if _merge == 2
drop _merge


preserve
import delimited "$pathDataExp/inputs/2022_03_29/A1_Oferta_Establecimientos_etapa_regular_2021_Admisión_2022.csv", clear charset(utf8)
rename rbd institution_code
collapse (sum) vacantes, by(institution_code)
tempfile vacantes
save `vacantes'
restore

merge m:1 institution_code using `vacantes'
drop if _merge == 2
drop _merge
rename vacantes vacantes_totales


preserve
import excel "$pathDataSM/Schools/Preescolar/ListadoJardinesPublicos_20220229163310.xls", clear firstrow cellrange(A2:V1723)
tempfile auxj
save `auxj'

import excel "$pathDataSM/Schools/Preescolar/ListadoJardinesPublicos_20220229163425.xls", clear firstrow cellrange(A2:V1474)
append using `auxj'

rename TELEFONOS telefono_contacto
rename CORREOELECTRONICO email

rename CODIGOUNIDADEDUCATIVA institution_code_prek
keep telefono_contacto email institution_code_prek
tempfile contactos
save `contactos'
restore

replace institution_code_prek = . if institution_code !=.

merge m:1 institution_code_prek using `contactos'
drop if _merge == 2
drop _merge
rename email email_junji
rename telefono_contacto telefono_contacto_junji


preserve
import delimited "$pathDataExp/inputs/2022_03_29/cb_explorer_chile_institutions_contact.csv", clear
keep if contact_label_id == 1
rename phone telefono_contacto_estab
rename cellphone celular_contacto_estab
rename email email_contacto_estab
keep institution_code telefono_contacto_estab celular_contacto_estab email_contacto_estab
duplicates drop institution_code, force
tempfile contactosestab
save `contactosestab'
restore

preserve
import delimited "$pathDataExp/inputs/2022_03_29/cb_explorer_chile_institutions_contact.csv", clear
keep if contact_label_id == 6
rename email email_director_estab
keep institution_code email_director_estab
duplicates drop institution_code, force
tempfile contactosdir
save `contactosdir'
restore


merge m:1 institution_code using `contactosestab'
drop if _merge == 2
drop _merge

merge m:1 institution_code using `contactosdir'
drop if _merge == 2
drop _merge


preserve
import delimited "$pathDataExp/inputs/2022_03_29/cb_explorer_chile_institutions_audiovisual.csv", clear charset(utf8)
gen tiene_drone = audiovisual_label_id == 1
gen tiene_tour= audiovisual_label_id == 2
gen tiene_testimonios= (audiovisual_label_id >= 3 & audiovisual_label_id <=6) | (audiovisual_label_id>=9 & audiovisual_label_id<=28)

collapse (max) tiene_drone tiene_tour tiene_testimonios, by(institution_code)
tempfile tours
save `tours'

restore


merge m:1 institution_code using `tours'
drop if _merge == 2
drop _merge
replace tiene_drone = 0 if tiene_drone == .
replace tiene_tour = 0 if tiene_tour == .
replace tiene_testimonios = 0 if tiene_testimonios == .

preserve
import delimited "$pathDataExp/inputs/2022_03_29/cb_explorer_chile_query_nuevos.csv", clear charset(utf8)
drop codigo_sede
replace geo_provincia_name = "Santiago" if regexm(geo_provincia_name,"Santiago")
tempfile nuevos
save `nuevos'
restore

append using `nuevos'
replace stage = "Preescolar" if stage == "" & (regexm(school_name,"Infantil") | regexm(school_name,"Sala Cuna"))
replace stage = "Preescolar" if stage == "" & regexm(school_name,"Centro Vitamina")

export delimited "$pathData/base_EEyJardines_Chile.csv", replace
