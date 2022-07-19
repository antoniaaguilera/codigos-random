
/*
================================================================================
FECHA CREACION: 2022-07-18
ULTIMA MODIFICACION: 2022-07-18 // akac
--------------------------------------------------------------------------------
PROYECTO: EXPLORADOR
OBJETIVO: GENERAR STOCK DEFINITIVO DE JARDINES PARA AGREGAR AL EXPLORADOR (
E INCORPORAR A SCHOOLING MARKETS EVENTUALMENTE)
================================================================================
*/

clear all
set more off

// Nombre de usuario
display "`c(username)'"

  if "`c(username)'"=="antoniaaguilera" { // Antonia
	   global pathData =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/"
  }

* ======================================================================= *
* =================  GENERAR STOCK A PARTIR DE EXPLORADOR  ============== *
* ======================================================================= *
* --- agregar latitud y longitud
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_location.csv", clear
keep institution_code latitud longitud address_street plocation_id campus_code

bys institution_code: keep if _n==1
tostring institution_code, replace
tempfile location
save `location', replace
* --- agregar comuna
import delimited "$pathData/latest_from_back/cb_explorer_chile_places_location.csv", clear
rename id plocation_id
reshape wide code_national@, i(plocation_id) j(label_subdivision) string
collapse (firstnm) code_nationalComuna, by(plocation_id)
rename code_nationalComuna geo_comuna
drop if plocation_id == .

merge 1:m plocation_id using `location'
keep if _merge == 3 //_m == 3 16788
drop _merge
bys institution_code: keep if _n == 1
tostring institution_code, replace

tempfile plocation
save `plocation', replace

* --- dependencia
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_campus.csv", clear charset(utf8)
tab grade_min
drop if grade_min == "1ro Básico" | grade_min == "1ro Medio" | grade_min == "2do Básico" | grade_min == "2do Medio" ///
| grade_min == "3ro Básico" | grade_min == "3ro Medio" |grade_min == "4to Básico" |grade_min == "4to Medio" | ///
grade_min == "5to Básico" |grade_min == "6to Básico" |grade_min == "7mo Básico" |grade_min == "7to Básico" |grade_min == "8vo Básico" | ///
grade_min == "Ed. Especial Laboral"


keep institution_code sector_label_id area_label_id campus_name grade_min
rename sector_label_id sector
bys institution_code: keep if _n == 1
gen urban = 1 if area_label_id == 1
replace urban = 0 if area_label_id ==2
replace urban = . if area_label_id == .

tostring institution_code, replace

merge 1:1 institution_code using `plocation'
keep if _merge == 3
drop _merge

tempfile stock_explorador
save `stock_explorador', replace


* ======================================================================= *
* ================= GENERAR STOCK A PARTIR DE DATA MINEDUC ============== *
* ======================================================================= *

import delimited "$pathData/inputs/jardines/20211112_Educacion_parvularia_oficial_2021_20210831_WEB.csv",  clear charset(utf8)

* - collapse
collapse (count) mat_parvularia = mrun (firstnm) rbd id_estab_i id_estab_j dependencia cod_com_estab cod_pro_estab cod_reg_estab nom_estab latitud longitud rural_estab, by(id_estab origen)

* - check for duplicates
duplicates report id_estab
duplicates tag id_estab, g(dup)

// los duplicados sólo son integra, hay duplicados junji.
count if dup>0 & id_estab_j!=" "
* - check number of centers by type
count if rbd!= " " //   7,519 con rbd,estos deberían pegar 100% con explorador
count if id_estab_j!= " " //   3,207
count if id_estab_i!= " " //   1,225

* - keep only ids for the mean time
keep rbd id_estab_i id_estab_j dependencia cod_com_estab nom_estab
gen institution_code = rbd
replace institution_code = id_estab_i + "_I" if id_estab_i != " "
replace institution_code = id_estab_j + "_J" if id_estab_j != " "
rename nom_estab campus_name
rename cod_com_estab geo_comuna


* ======================================================================= *
* ================= GENERAR STOCK A PARTIR DE DATA MINEDUC ============== *
* ======================================================================= *
merge 1:1 institution_code using `stock_explorador', update

tab sector if _merge >=3
tab dependencia if _merge == 1

* --- revisar potenciales duplicados
replace campus_name = ustrtitle(campus_name)

duplicates tag campus_name geo_comuna, g(dup)
sort campus_name geo_comuna
br if dup>0
sort campus_name  geo_comuna


* --- generar codigo parvulo
destring id_estab_i id_estab_j, replace
bys campus_name geo_comuna: egen codigo_parvulo = max(id_estab_j)      if dup==1
bys campus_name geo_comuna: ereplace codigo_parvulo = max(id_estab_i)  if dup==1 & codigo_parvulo == .
bys campus_name geo_comuna: ereplace dependencia = max(dependencia)
tostring codigo_parvulo, replace

replace codigo_parvulo = codigo_parvulo + "_J" if dependencia == 4 & dup==1
replace codigo_parvulo = codigo_parvulo + "_I" if dependencia == 5 & dup==1
sort campus_name geo_comuna institution_code
order institution_code id_* rbd codigo_parvulo

* --- max instution_code
gen def_institution_code = institution_code if id_estab_i == . & id_estab_j ==.
destring def_institution_code, replace
bys campus_name geo_comuna: ereplace def_institution_code = max(def_institution_code)

* --- drop duplicates
drop if dup == 1 & _merge == 1
duplicates tag def_institution_code, g(dup2)
br if dup2>0 & dup>0 // 129

* --- flag duplicates
gen flag = 1 if dup2>0 & dup>0
sort campus_name geo_comuna
unique campus_name geo_comuna if flag == 1 //43 unique cases

* --- mannually fix 43 cases
* vitamina san carlos
drop if campus_name == "Centro  Vitamina San Carlos De Apoquindo" & geo_comuna == 13114 & institution_code != "41724"
replace dependencia = 3 if  institution_code == "41724"
replace flag = . if institution_code == "41724"

* antiquina, cañete
drop if campus_name == "Antiquina" & geo_comuna == 8203 & institution_code != "36882"
replace codigo_parvulo = "84704_I" if institution_code == "36882"
replace dependencia = 5 if institution_code == "36882"
replace flag = . if institution_code == "36882"

* arturo prat chacon de talcahuano
replace campus_name = "Colegio Arturo Prat Chacon" if institution_code == "4796"
replace campus_name = "Escuela Arturo Prat Chacon" if institution_code == "4711"
replace flag = . if institution_code == "4796" | institution_code == "4711"

* campanita, nancagua -> PENDIENTE

* CANDELARIA, SAN PEDRO DE LA PAZ
replace dependencia = 5 if institution_code == "36894"
replace codigo_parvulo = "85103_I" if institution_code == "36894"
drop if institution_code == "85103_I"

* centro educacional menesiano, melipilla
drop if institution_code == "36053"
replace flag = . if institution_code == "10833"

* vitamina suecia
drop if institution_code == "41166"
replace flag = . if institution_code == "41458"

* el redentor de maipú
replace campus_name = "Colegio El Redentor Anexo" if institution_code == "24954"
replace flag = . if institution_code == "24954" | institution_code == "9950"

* colegio preston school, hualpén
drop if institution_code == "18163"
replace flag = . if institution_code == "41702"

* colegio san fernando
replace campus_name = "Colegio San Fernando Los Notros" if institution_code == "17834"
replace flag = . if institution_code == "17834" | institution_code == "17895"

*  trencito de petorca
replace codigo_parvulo = "50203_I"   if institution_code == "36485"
replace codigo_parvulo = "5404107_J" if institution_code == "33554"
drop if institution_code == "5404107_J" |institution_code == "50203_I"
replace flag = . if institution_code == "36485" | institution_code == "33554"

* sueños de niños, talca
drop if institution_code == "7101032_J"
drop if institution_code == "36676"
replace codigo_parvulo = "71008_I"  if institution_code=="33954"
drop if institution_code == "71008_I"
replace flag = . if institution_code == "33954"

* san miguel, pemuco
drop if institution_code == "16105009_J"
drop if institution_code == "170503_I"
replace codigo_parvulo = "170503_I" if institution_code == "36783"
replace flag = . if institution_code == "36783"

* entre niños, cerrillos
*ESPERANDO RESPUESTA

* ARTURO PEREZ CANTO, QUILICURA
drop if institution_code == "41837"
replace codigo_parvulo = "143201_I" if institution_code == "37351"
replace flag = . if institution_code == "37351"

* smile garden
//41004 es los leones

* mundo feliz
//ESPERANDO RESPUESTA

* Bicentenario, retiro
// Pendiente

* Marcela Paz, Santiago
*replace codigo_parvulo = "13101024_I" if
// ESPERANDO RESPUESTA

* LOS AVELLANOS
replace codigo_parvulo = "131319_I" if institution_code == "37191"
drop if institution_code == "41689"
replace flag = . if institution_code == "37191"

* RAYITO DE SOL COLLIPULLI
//Esperando respuesta

* ---- hasta acá estoy segura de las decisiones
br if flag == 1 & campus_name == "Sueños De Niños"
br if flag ==1
* colegio san jorge el laja
drop if institution_code == "41899"
replace flag = . if institution_code == "4499"

* colegio san pablo en Los angeles
*drop if institution_code == "17786"
*replace flag = . if institution_code == "20392"
* jardin infantil cuncunita rbd 7756

* el mundo de winny, independencia
* 41741, sale en el listado de jardines privados pero estoy esperando confirmación
drop if institution_code == "41742" | institution_code == "41743" | institution_code == "41744"
replace flag = . if institution_code == "41741"

* los peques ovalle
replace address_street = " CALLE UNICA S/N ALCONES BAJOS"
br if flag == 1
