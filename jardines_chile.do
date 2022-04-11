/*
================================================================================
FECHA CREACION: 2022-04-07
ULTIMA MODIFICACION: 2022-04-07 // akac
--------------------------------------------------------------------------------
PROYECTO: Schooling_Markets_Chile / Jardines
================================================================================
*/

/*
- [ ]  juntar todo lo que es exclusivamente jardines
- [ ]  ver el match.
- [ ]  ahí entregar contacto
- [ ]  después sumar a vista previa (soloreconocido oficialmente) y colapsar
*/

clear all
set more off


* ============================================================= *
* ========================== PREÁMBULO ======================== *
* ============================================================= *
// Nombre de usuario
display "`c(username)'"

  if "`c(username)'"=="antoniaaguilera" { // Antonia
    global pathData =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile"
	global pathDataExplorador =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/"
	global pathRandom = "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/data_random"
  }

  if "`c(username)'"=="ij1376" { // Isa
    global pathData =  "C:/Users/ij1376/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile"
	global pathDataExplorador =  "C:/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
  global pathRandom = "C:/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/data/"
  }

{
* ============================================================= *
* ================== LISTADO JARDINES PUBLICOS ================ *
* ============================================================= *
import excel "$pathData/Schools/Preescolar/ListadoJardinesPublicos_20220229163310.xls", sheet("JARDINES PUBLICOS") firstrow clear

gen origen = 2
gen sector_label_id = 7
tempfile municipales
save `municipales', replace

* ============================================================= *
* ================== LISTADO JARDINES PUBLICOS ================ *
* ============================================================= *
import excel "$pathData/Schools/Preescolar/ListadoJardinesPublicos_20220229163425.xls", clear firstrow locale("utf8")

gen origen = 2
gen sector_label_id = 7
append using `municipales'

rename (CODIGOUNIDADEDUCATIVA NOMBREESTABLECIMIENTO REGION COMUNA) (id_estab nom_estab nom_reg_estab nom_com_estab)
replace nom_estab = upper(nom_estab)

replace nom_reg_estab = "REGIÓN DE TARAPACÁ" if nom_reg_estab == "REGIÓN DE TARAPACÁ "
* --- arreglar nombres
replace nom_estab = trim(nom_estab)
replace nom_estab = subinstr(nom_estab, "ñ", "Ñ",.)
replace nom_estab = subinstr(nom_estab, "ã‘", "Ñ",.)
replace nom_estab = subinstr(nom_estab, "á", "A",.)
replace nom_estab = subinstr(nom_estab, "é", "E",.)
replace nom_estab = subinstr(nom_estab, "í", "I",.)
replace nom_estab = subinstr(nom_estab, "ó", "O",.)
replace nom_estab = subinstr(nom_estab, "ú", "U",.)
replace nom_estab = subinstr(nom_estab, "ï", "I",.)
replace nom_estab = subinstr(nom_estab, "ü", "U",.)
replace nom_estab = subinstr(nom_estab, "ãš", "U",.)

replace nom_estab = subinstr(nom_estab, "PMI ", "",.)

replace nom_estab = subinstr(nom_estab, "  ", " ",.)
replace nom_estab = subinstr(nom_estab, " - ", "-",.)
replace nom_estab = subinstr(nom_estab, "-", " ",.)
replace nom_estab = subinstr(nom_estab, "CASH ", "",.)
replace nom_estab = subinstr(nom_estab, "CECI ", "",.)
replace nom_estab = subinstr(nom_estab, "COIGUE", "COIHUE",.)
replace nom_estab = subinstr(nom_estab, "VILLA LOS ANDES DE CACHAPOAL", "VILLA LOS ANDES CACHAPOAL",.)
replace nom_estab = subinstr(nom_estab, "PEQUEÑAS SEMILLAS", "PEQUEÑAS SEMILLITAS",.)

gen base = "junjilistado"

* --regiones
gen cod_reg_estab = .
replace cod_reg_estab = 1	if nom_reg_estab == "REGIÓN DE TARAPACÁ"
replace cod_reg_estab = 2 	if nom_reg_estab == "REGIÓN DE ANTOFAGASTA"
replace cod_reg_estab = 3 	if nom_reg_estab == "REGIÓN DE ATACAMA"
replace cod_reg_estab = 4	if nom_reg_estab == "REGIÓN DE COQUIMBO"
replace cod_reg_estab = 5	if nom_reg_estab == "REGIÓN DE VALPARAÍSO"
replace cod_reg_estab = 6	if nom_reg_estab == "REGIÓN DEL LIBERTADOR BERNARDO O´HIGGINS"
replace cod_reg_estab = 7	if nom_reg_estab == "REGIÓN DE MAULE"
replace cod_reg_estab = 8	if nom_reg_estab == "REGIÓN DE BIO BIO"
replace cod_reg_estab = 9	if nom_reg_estab == "REGIÓN DE LA ARAUCANÍA"
replace cod_reg_estab = 10	if nom_reg_estab == "REGIÓN DE LOS LAGOS"
replace cod_reg_estab = 11	if nom_reg_estab == "REGIÓN DE AYSÉN DEL GRAL. CARLOS IBÁÑEZ DEL CAMPO"
replace cod_reg_estab = 12	if nom_reg_estab == "REGIÓN DE MAGALLANES Y ANTÁRTICA CHILENA"
replace cod_reg_estab = 13	if nom_reg_estab == "REGIÓN METROPOLITANA"
replace cod_reg_estab = 14	if nom_reg_estab == "REGIÓN DE LOS RÍOS"
replace cod_reg_estab = 15 	if nom_reg_estab == "REGIÓN DE ARICA Y PARINACOTA"
replace cod_reg_estab = 16	if nom_reg_estab == "REGIÓN DE ÑUBLE"

tempfile junji_municipales
save `junji_municipales', replace //3,193

* ============================================================= *
* ==================== MATRICULA PREESCOLAR =================== *
* ============================================================= *
* --- base pública de matrícula preescolar
import delimited "$pathData/Schools/Preescolar/20211112_Educacion_parvularia_oficial_2021_20210831_WEB.csv", clear charset(utf8)
* --- colapso a nivel de id_estab origen
collapse (firstnm) cod_ense1_m cod_ense2_m nom_estab nom_reg_a_estab nom_com_estab nom_pro_estab cod_depe1_m estado_estab_m id_estab_j id_estab_i rbd latitud longitud dependencia (mean) cod_reg_estab cod_pro_estab cod_com_estab rural_estab (count) matricula_preescolar = mrun , by(id_estab origen)

tempfile aux
save `aux'

* --- resumen de matricula preescolar
import delimited "$pathData/Schools/Preescolar/20211122_Resumen_Educacion_Parvularia_por_EE_2021_20210831.csv", clear charset(utf8)
merge 1:1 id_estab origen using `aux', keepusing(latitud longitud dependencia cod_ense1_m cod_ense2_m)
drop _merge //deberían pegar todos
gen base = "mineduc"
* --- arreglos nombres
replace nom_estab = trim(nom_estab)
replace nom_estab = subinstr(nom_estab, " - ", "-",.)
replace nom_estab = subinstr(nom_estab, "-", " ",.)
replace nom_estab = subinstr(nom_estab, "  ", " ",.)
replace nom_estab = subinstr(nom_estab, "Á", "A",.)
replace nom_estab = subinstr(nom_estab, "É", "E",.)
replace nom_estab = subinstr(nom_estab, "Í", "I",.)
replace nom_estab = subinstr(nom_estab, "Ó", "O",.)
replace nom_estab = subinstr(nom_estab, "Ú", "U",.)
replace nom_estab = subinstr(nom_estab, "Ï", "I",.)
replace nom_estab = subinstr(nom_estab, "Ü", "U",.)

replace nom_estab = subinstr(nom_estab, "PMI ", "",.)

replace nom_estab = subinstr(nom_estab, "PEQUENO", "PEQUEÑO",.)
replace nom_estab = subinstr(nom_estab, "COIGUE", "COIHUE",.)
replace nom_estab = subinstr(nom_estab, "DOMEYCO", "DOMEYKO",.)
replace nom_estab = subinstr(nom_estab, "CASH ", "",.)
replace nom_estab = subinstr(nom_estab, "CECI ", "",.)
replace nom_estab = subinstr(nom_estab, "NUEVA ALDEA TRENCITO DE NUEVA", "NUEVA ALDEA TRENCITO DE NUEVA ALDEA",.)
replace nom_estab = subinstr(nom_estab, "SUEÑO DE NIÑOS", "SUEÑOS DE NIÑOS",.)
replace nom_estab = subinstr(nom_estab, "AROMITOS", "LOS AROMITOS",.)
replace nom_estab = subinstr(nom_estab, "RABITO, SUEÑO DE ARTISTAS", "RABITO, SUEÑOS DE ARTISTA",.)
replace nom_estab = subinstr(nom_estab, "ÑUKE MAPU", "ÑUKE MAPU DE QUILVO",.)


* --- pegar listado jardines
merge m:1 id_estab nom_estab using `junji_municipales', update //pegan 3014
rename (_merge TELEFONO CORREOELECTRONICO DIRECCIONDELESTABLECIMIENTO) (merge_listado_mineduc phone mail address)

* --- arreglos varios
gen cod_ense = cod_ense1_m
replace cod_ense = "10" if cod_ense1_m == " "
destring cod_ense, replace

* --- arreglar lat lons
replace latitud = subinstr(latitud,"0-","-",.)
replace longitud = subinstr(longitud,"0-","-",.)
destring latitud longitud, replace

replace latitud = LATITUD if latitud ==. & LATITUD !=.
replace longitud = LONGITUD if longitud ==. & LONGITUD !=.

* --- matricula preescolar
gen sc_may_si =0
foreach level in sc_men sc_may med_men med_may nt1 nt2 {
	gen mat_`level' = `level'_si + `level'_h + `level'_m
}

gen urban =(rural_estab==0)
replace urban = . if rural_estab==.

keep id_estab nom_estab cod_ense cod_com_estab cod_pro_estab cod_reg_estab mat_nt2 mat_nt1 mat_med_may mat_sc_may mat_sc_men latitud longitud dependencia origen urban RECONOCIMIENTOOFICIAL base dependencia sector_label_id phone mail address

replace nom_estab = subinstr(nom_estab, "PMI ", "",.)

collapse (firstnm) phone mail address dependencia sector_label_id base urban mat_* latitud longitud cod_com_estab cod_pro_estab cod_reg_estab, by(id_estab nom_estab origen RECONOCIMIENTOOFICIAL)

duplicates tag id_estab origen, g(dup)
sort id_estab origen

* --- conservar nombre junji y datos mineduc
gsort id_estab origen base
collapse (firstnm)base phone mail address dup dependencia sector_label_id nom_estab urban mat_* latitud longitud cod_com_estab cod_pro_estab cod_reg_estab, by(id_estab origen)

* --- id integra
tostring id_estab origen, replace
replace id_estab = id_estab + "-I" if origen =="3"
duplicates report id_estab

* ---  sector_label_id
tab dependencia
replace sector_label_id = 1 if dependencia == 1 //municipal->público
replace sector_label_id = 2 if dependencia == 2 //subvencionado
replace sector_label_id = 3 if dependencia == 3 //particular
replace sector_label_id = 5 if dependencia == 6 //servicio local
replace sector_label_id = 7 if dependencia == 4 | origen == "2" //junji
replace sector_label_id = 8 if dependencia == 5 | origen == "3" //integra

rename (id_estab nom_estab sector_label_id cod_reg_estab cod_pro_estab cod_com_estab) (institution_code school_name type geo_region geo_provincia geo_comuna)

gen matricula_preescolar = mat_med_may + mat_nt1 + mat_nt2 + mat_sc_may + mat_sc_men

gen preescolar = 1

merge m:1 geo_comuna using "$pathRandom/codigos_geo.dta"
drop if _merge == 2

preserve
keep institution_code school_name type urban latitud longitud geo_region geo_provincia geo_comuna matricula_preescolar preescolar //geo_region_name geo_provincia_name geo_comuna_name
order institution_code school_name type urban latitud longitud geo_region geo_provincia geo_comuna matricula_preescolar preescolar //geo_region_name geo_provincia_name geo_comuna_name

export delimited "$pathDataExplorador/inputs/JARDINES/base_jardines.csv", replace
restore
}

* ============================================================= *
* ======================= CONTACTO JUNJI ====================== *
* ============================================================= *

split phone, generate(phone2)
drop phone21 phone22 phone24 phone25 phone26 phone
rename (phone27 phone23) (phone_2 phone_1)

keep institution_code school_name type latitud longitud address phone_1 phone_2 mail geo_comuna geo_region geo_comuna_name geo_region_name base

tempfile contact
save `contact'

* --- pegar info de jardines que ya tenemos
import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_places_location.csv", clear charset(utf8) delimiter(",")
keep if label_subdivision == "Region"
tempfile region
save `region'

import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_places_location.csv", clear charset(utf8) delimiter(",")
keep if label_subdivision == "Provincia"
rename id pid
rename upper_location_id id
rename (name code_national) (geo_provincia_name geo_provincia)
keep pid geo_provincia* id
merge m:1 id using `region'
drop id
rename pid id
keep id name code_national
rename (name code_national) (geo_region_name geo_region)
tempfile provregion
save `provregion'


import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_places_location.csv", clear charset(utf8) delimiter(",")
rename id pid
rename upper_location_id id
rename (name code_national) (geo_comuna_name geo_comuna)
keep if label_subdivision == "Comuna"
keep pid geo_comuna* id
merge m:1 id using `provregion'
keep pid geo_comuna geo_comuna_name geo_region geo_region_name
rename pid plocation_id
tempfile plocation
save `plocation'


import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_institutions_location.csv", clear charset(utf8) delimiter(",")
merge m:1 plocation_id using `plocation'
keep latitud longitud institution_code campus_code geo*
sort institution_code campus_code
bys institution_code: keep if _n == 1
drop campus_code
tempfile location
save `location'

import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_institutions_campus.csv", clear charset(utf8) delimiter(",")
keep institution_code sector_id
duplicates drop institution_code, force
rename sector_id type

tempfile type
save `type'



import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_institutions_institutions.csv", clear charset(utf8) delimiter(",")
merge 1:1 institution_code using `type'
drop _merge

keep if grade_max == "Atención Temprana" | grade_max == "Kinder (Nivel de Transición 2)" | grade_max == "Nivel Medio Heterogéneo" | grade_max == "Nivel Medio Mayor" | grade_max == "Nivel Medio Menor" | grade_max == "Nivel Transición Heterogéneo" | grade_max == "Nivel de Transición 1" | grade_max == "Nivel de Transición 2" | grade_max == "Parvularia Heterogéneo" | grade_max == "PreKinder (Nivel de Transición 1)" | grade_max == "Sala Cuna Heterogéneo" | ///
 grade_max == "Sala Cuna Mayor" | grade_max == "Sala Cuna Menor" | grade_max == "Sin Información"
tab grade_max grade_min
drop if grade_min == "1° básico" | grade_min == "2° básico"  | grade_min == "3° básico" | grade_min == "4° básico" | grade_min == "6° básico" | grade_min == "7° básico" | grade_min == "Laboral 1"

merge 1:1 institution_code using `location'
drop if _merge == 2
drop _merge
keep institution_name institution_code latitud longitud geo* type
tempfile names
save `names'

import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_institutions_contact.csv", clear charset(utf8) delimiter(",")
drop name
merge m:1 institution_code using `names'
drop if _merge == 1
drop _merge

keep if contact_label_id == 1
tostring institution_code, replace
sort institution_code campus_code
bys institution_code: keep if _n==1
gen base = "explorador (mineduc)"


merge 1:1 institution_code using `contact', update
replace school_name = institution_name if institution_name != "" & school_name == ""
drop institution_name
drop _merge

sort institution_code
order institution_code
drop id
*drop if _merge==1
*drop _merge

replace mail = email if mail==""
format phone %30.0g
destring phone* , replace
replace phone_1 = phone if phone_1 == .
replace phone_2 = cellphone if phone_2 == .

format phone_1 phone_2 %30.0g
drop phone cellphone
replace mail = "" if mail == "@"
tempfile todos_ee
save `todos_ee', replace

* ============================================================= *
* ================== BASE PRIVADOS SCRAPPEADA ================= *
* ============================================================= *
import delimited "$pathDataExplorador/inputs/JARDINES/Jardines.csv", clear charset(utf8)
replace nombre = upper(nombre)
replace nombre = subinstr(nombre, "ñ", "Ñ",.)
replace nombre = subinstr(nombre, "ã`", "Ñ",.)
replace nombre = subinstr(nombre, "á", "A",.)
replace nombre = subinstr(nombre, "é", "E",.)
replace nombre = subinstr(nombre, "í", "I",.)
replace nombre = subinstr(nombre, "ó", "O",.)
replace nombre = subinstr(nombre, "ú", "U",.)
replace nombre = subinstr(nombre, "ï", "I",.)
replace nombre = subinstr(nombre, "ü", "U",.)

replace telfono =subinstr(telfono, " ", "",.)
replace telfono =subinstr(telfono, "+56", "",.)
replace telfono = subinstr(telfono, "-", "",.)
replace telfono = subinstr(telfono, "NoRegistraTeléfono", "",.)
replace telfono = subinstr(telfono, "|", " ",.)
split telfono, generate(phone_)
destring phone_*, replace

replace ubicacin = subinstr(ubicacin, "RM / ", "",.)
replace ubicacin = subinstr(ubicacin, " / RM", "",.)
replace ubicacin = upper(ubicacin)
replace ubicacin = subinstr(ubicacin, "ñ", "Ñ",.)
replace ubicacin = subinstr(ubicacin, "á", "A",.)
replace ubicacin = subinstr(ubicacin, "é", "E",.)
replace ubicacin = subinstr(ubicacin, "í", "I",.)
replace ubicacin = subinstr(ubicacin, "ó", "O",.)
replace ubicacin = subinstr(ubicacin, "ú", "U",.)
replace ubicacin = subinstr(ubicacin, "ï", "I",.)
replace ubicacin = subinstr(ubicacin, "ü", "U",.)

keep if establecimiento == "Particular"
rename(nombre direccion ubicacin)(school_name address geo_comuna_name)
keep school_name latitud longitud address phone_1 phone_2 geo_comuna_name

gen type = 3
gen geo_region = 13 //son solo RM

gen base ="privados"
replace geo_comuna_name = "SANTIAGO" if school_name=="VITAMINA SAN FRANCISCO"
merge m:1 geo_comuna_name using "$pathRandom/codigos_geo.dta"
keep if _merge ==3
drop _merge

append using `todos_ee'

tempfile privados
save `privados'


* ============================================================= *
* ================== BASE INTEGRA SCRAPPEADA ================= *
* ============================================================= *
import delimited "$pathDataExplorador/inputs/JARDINES/integra.csv", clear charset(utf8)
gen type = 8
gen base ="integra"
rename (nombre coord_* direccion correo telefono comuna)(school_name * address mail phone_1 geo_comuna_name)
keep school_name latitud longitud address mail phone_1 geo_comuna_name type base
replace geo_comuna_name =strtrim(geo_comuna_name)
replace geo_comuna_name = subinstr(geo_comuna_name, "ñ", "Ñ",.)
replace geo_comuna_name = subinstr(geo_comuna_name, "Á", "A",.)
replace geo_comuna_name = subinstr(geo_comuna_name, "É", "E",.)
replace geo_comuna_name = subinstr(geo_comuna_name, "Í", "I",.)
replace geo_comuna_name = subinstr(geo_comuna_name, "Ó", "O",.)
replace geo_comuna_name = subinstr(geo_comuna_name, "Ú", "U",.)

replace geo_comuna_name = "YERBAS BUENAS" if geo_comuna_name =="YERBA BUENA"
replace geo_comuna_name = "TREHUACO" if geo_comuna_name =="TREGUACO"
replace geo_comuna_name = "PUQUELDON" if geo_comuna_name =="PULQUEDON"
replace geo_comuna_name = "O'HIGGINS" if geo_comuna_name =="OHIGGINS"
replace geo_comuna_name = "PUQUELDON" if geo_comuna_name =="PULQUEDON"
replace geo_comuna_name = "ERCILLA" if geo_comuna_name==""

merge m:1 geo_comuna_name using "$pathRandom/codigos_geo.dta"
keep if _merge ==3
drop _merge

append using `privados'

keep institution_code school_name address geo_comuna_name geo_comuna geo_region latitud longitud  phone_1 phone_2 email  type base webpage
order institution_code school_name address geo_comuna_name geo_comuna geo_region latitud longitud  phone_1 phone_2 email  type base webpage
format phone_* %30.0g

bys school_name latitud longitud: egen max_lat=max(lat)
bys school_name latitud longitud: egen max_lon=max(lon)

collapse (firstnm) address phone_1 phone_2 email base webpage institution_code geo_comuna geo_comuna_name geo_region , by(school_name max_lat max_lon type)

rename (max_lat max_lon)(latitud longitud)

duplicates tag school_name geo_comuna_name geo_region type, gen(duplicado)
gen esta_duplicado = (duplicado>0)
drop duplicado

gen type_label = "Público" if type == 1
replace type_label = "Particular Subvencionado" if type == 2
replace type_label = "Particular Pagado" if type == 3
replace type_label = "Corporación de Administración Delegada" if type == 4
replace type_label = "Servicio Local de Educación" if type == 5
replace type_label = "Sin Información" if type == 6
replace type_label = "JUNJI" if type == 7
replace type_label = "Integra" if type == 8

replace school_name = upper(school_name)
replace school_name = subinstr(school_name, "ñ", "Ñ",.)
replace school_name = subinstr(school_name, "á", "A",.)
replace school_name = subinstr(school_name, "é", "E",.)
replace school_name = subinstr(school_name, "í", "I",.)
replace school_name = subinstr(school_name, "ó", "O",.)
replace school_name = subinstr(school_name, "ú", "U",.)
replace school_name = subinstr(school_name, "ï", "I",.)
replace school_name = subinstr(school_name, "ü", "U",.)


tab base
tab type_label base

replace base = "base " + base
order institution_code school_name type type_label base geo_comuna geo_comuna_name geo_region latitud longitud address phone_1 phone_2 email webpage  esta_duplicado

export delimited "$pathDataExplorador/inputs/JARDINES/contacto_jardines.csv", replace
