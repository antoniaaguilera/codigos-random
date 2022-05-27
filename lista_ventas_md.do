/*
================================================================================
FECHA CREACION: 2022-05-10
ULTIMA MODIFICACION: 2022-05-10 // ijacas
--------------------------------------------------------------------------------
PROYECTO: Tether
================================================================================
*/

clear all
set more off

// Nombre de usuario
display "`c(username)'"

if "`c(username)'"=="ijacas" { // Isa
    global pathData =  "C:/Users/ijacas/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
    global pathTether = "C:/Users/ijacas/ConsiliumBots Dropbox/Isabel Jacas/data/bases andrea_marcy/"
}

* ============================================================= *
* ============================================================= *
* ======================== FROM BACK ========================== *
* ============================================================= *
* ============================================================= *

/*
Vamos a obtener del back:
- Lista de colegios, con dependencia (campus)
- Comuna y region (location)
- Categoria de desempeño (quality categ)
- Matricula total (members)
- Vacantes (program)
- Capacidad (SAE A)
- SNED (SNED)
- Copago (Payment)
- Subejecución (Ingresos y Gastos)
*/



// Location, seteamos las location id para pegarle comuna, provincia y region
import delimited "$pathData/latest_from_back/cb_explorer_chile_places_location.csv", clear
preserve
keep if label_subdivision == "Region"
keep id code_national name
rename (id code_national name) (upper_location_id cod_reg name_reg)
tempfile regiones
save `regiones'
restore

preserve
keep if label_subdivision == "Provincia"
keep id code_national name upper_location_id
merge m:1 upper_location_id using `regiones', keep(3) nogen
drop upper_location_id
rename (id code_national name) (upper_location_id cod_prov name_prov)
tempfile provincias
save `provincias'
restore

keep if label_subdivision == "Comuna"
keep id code_national name upper_location_id
merge m:1 upper_location_id using `provincias', keep(3) nogen
drop upper_location_id
rename (id code_national name) (plocation_id cod_com name_com)

tempfile comunas
save `comunas'


import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_location.csv", clear
merge m:1 plocation_id using `comunas'
keep campus_code cod_com name_com cod_reg name_reg
tempfile location
save `location'



// Categoria de desempeño, nos quedamos con ambas (basica y media)
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_qualitymeasure_categ.csv", clear
tab qualitymeasure_categ_label_id
// 1 es Basica y 2 es Media
keep campus_code qualitycateglevel_id qualitymeasure_categ_label_id

reshape wide qualitycateglevel_id, i(campus_code) j(qualitymeasure_categ_label_id)
rename (qualitycateglevel_id1 qualitycateglevel_id2) (cat_des_basica cat_des_media)

tempfile catdes
save `catdes'




// Matricula total del establecimiento
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_member.csv", clear
keep if member_label_id == 1
keep campus_code total_members
collapse (sum) total_members, by(campus_code)
rename total_members mat_total
tempfile mat_total
save `mat_total'



// Vacantes
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_program.csv", clear
keep campus_code regular_vacancies
collapse (sum) regular_vacancies, by(campus_code)
rename regular_vacancies vacantes
tempfile vacantes
save `vacantes'


// Capacidad
import delimited "$pathData/inputs/2022_04_05/SAE_2021/A1_Oferta_Establecimientos_etapa_regular_2021_Admisión_2022.csv", clear charset(utf8) delimiter(";")
keep rbd cupos_totales
collapse (sum) cupos_totales, by(rbd)

rename (rbd cupos_totales) (institution_code capacidad)

tempfile capacidad
save `capacidad'



// SNED
import delimited "$pathData/inputs/2022_04_05/SNED_2020-2021/20201104_SNED_2020_2021.csv", clear charset(utf8) delimiter(";")

keep rbd sel
gen SNED = 0 if sel == 3
replace SNED = 60 if sel == 2
replace SNED = 100 if sel == 1
keep rbd SNED
rename rbd institution_code

tempfile SNED
save `SNED'


// Payments
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_payment_category_label.csv", clear charset(utf8)
rename id payment_category_label_id
keep payment_category_label_id payment_category_name
tempfile labelspayment
save `labelspayment'

import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_payment.csv", clear
merge m:1 payment_category_label_id using `labelspayment', nogen keep(3)
keep campus_code payment_category_name

tempfile payment
save `payment'


import delimited "$pathData/inputs/2022_04_05/Gastos e Ingresos/EERR_2020.csv", clear charset(utf8) delimiter(",")
replace monto_declarado = subinstr(monto_declarado,",","",.)
replace monto_declarado = subinstr(monto_declarado," ","",.)
replace monto_declarado = "" if monto_declarado == "-"
destring monto_declarado, replace
tab desc_tipo_cuenta

keep if desc_tipo_cuenta == "SALDO FINAL"

tab subvencion_alias

keep if subvencion_alias == "GENERAL" | subvencion_alias == "SEP"
drop if monto_declarado ==.

gen subv = 1 if subvencion_alias == "GENERAL"
replace subv = 2 if subvencion_alias == "SEP"

duplicates tag sost_id rbd, gen(dup)
drop dup

keep nombre_sost monto_declarado rbd subv

reshape wide monto_declarado, i(rbd nombre_sost) j(subv)
bysort rbd: gen n_sost = _n
rename (monto_declarado1 monto_declarado2) (monto_Gral monto_SEP)
reshape wide monto_Gral monto_SEP nombre_sost, i(rbd) j(n_sost)
rename (monto_Gral1 monto_SEP1 monto_Gral2 monto_SEP2) (ejecucion_gral_1 ejecucion_SEP_1 ejecucion_gral_2 ejecucion_SEP_2)
rename (nombre_sost1 nombre_sost2) (sostenedor_1 sostenedor_2)
destring rbd, replace
rename rbd institution_code


tempfile ejecucion
save `ejecucion'





// Campus, unimos todo
import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_sector_label.csv", clear charset(utf8)
rename id sector_id
keep sector_id sector_name
tempfile sector
save `sector'



import delimited "$pathData/latest_from_back/cb_explorer_chile_institutions_campus.csv", clear charset(utf8)
merge m:1 sector_id using `sector', nogen keep(3)
keep campus_code campus_name institution_code sector_name area_id academy_id
gen rural = area_id == 2
drop area_id


merge 1:1 campus_code using `location', keep(3) nogen
merge 1:1 campus_code using `catdes', keep(1 3) nogen
merge 1:1 campus_code using `mat_total', keep(1 3) nogen
merge 1:1 campus_code using `vacantes', keep(1 3) nogen
merge 1:1 campus_code using `payment', keep(1 3) nogen

sort campus_code
drop campus_code
collapse (sum) vacantes mat_total (max) cat_des_basica cat_des_media rural (firstnm) payment_category_name campus_name, by(institution_code cod_com name_com cod_reg name_reg)
duplicates report institution_code


merge 1:1 institution_code using `capacidad', keep(1 3) nogen
merge 1:1 institution_code using `SNED', keep(1 3) nogen
merge 1:1 institution_code using `ejecucion', keep(1 3) nogen


rename campus_name nombre_colegio
rename institution_code rbd

order rbd nombre_colegio
export delimited "$pathTether/lista_establecimientos.csv", replace
export excel "$pathTether/lista_establecimientos.xlsx", replace firstrow(variables)
