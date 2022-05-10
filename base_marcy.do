/*
================================================================================
FECHA CREACION: 2022-02-25
ULTIMA MODIFICACION: 2022-02-25 // akac
--------------------------------------------------------------------------------
PROYECTO: Schooling_Markets_Chile
================================================================================
*/

clear all
set more off

// Nombre de usuario
display "`c(username)'"

  if "`c(username)'"=="antoniaaguilera" { // Antonia
    global pathData =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile/"
	global pathDataExplorador =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/"
    global pathFromBack =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/latest_from_back"
	global pathRandom = "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/random_data/"
  }
  
* ============================================================ *
* ==================== INFO DESDE EXPLORADOR ================= *
* ============================================================ *

* --- agregar dirección 
import delimited "$pathFromBack/cb_explorer_chile_institutions_location.csv", clear
keep institution_code campus_code address_street
*bys institution_code: keep if _n==1
tempfile location
save `location', replace 

* --- agregar información de contacto
import delimited "$pathFromBack/cb_explorer_chile_institutions_contact.csv", clear
reshape wide phone webpage name cellphone email , i(id) j(contact_label_id)

collapse (firstnm) phone* cellphone* email* webpage* name*, by(institution_code) 

drop phone5 phone6 cellphone5 cellphone6 email5 webpage2 webpage5 webpage6 name5 name6

rename (*1 *2 *6)(*_ofprincipal *_cepadres *_director)

merge 1:m institution_code using `location'
drop _merge
tempfile contact
save `contact', replace 

* --- agregar nombres directores
import delimited "$pathDataExplorador/inputs/2022_02_03/datos_directores_2022-02-22.csv", clear  
drop if estado_estab == 2
gen name_director = dire_nombres+" "+dire_paterno+" "+dire_materno
rename rbd institution_code
drop if mail_director == "@" 
keep institution_code name_director mail_director
* --- merge con contacts
merge 1:m institution_code using `contact', update
drop _merge 
replace email_director = mail_director if email_director == ""|email_director == " "

tostring institution_code, replace 

gen desde_explorador = 1
 
tempfile contacto_explorador
save `contacto_explorador', replace 
 
* ============================================================ *
* ======================= INFO DESDE JUNJI =================== *
* ============================================================ *
* --- municipales
import excel "$pathData/Schools/Preescolar/ListadoJardinesPublicos_20220229163310.xls", sheet("JARDINES PUBLICOS") firstrow clear

tempfile municipales
save `municipales', replace

* --- junji no municipales
import excel "$pathData/Schools/Preescolar/ListadoJardinesPublicos_20220229163425.xls", clear firstrow locale("utf8")

append using `municipales'

rename (CODIGOUNIDADEDUCATIVA NOMBREESTABLECIMIENTO REGION COMUNA) (id_estab nom_estab nom_reg_estab nom_com_estab)

* --- arreglar nombre 
replace nom_estab = upper(nom_estab)
replace nom_estab = trim(nom_estab)
replace nom_estab = subinstr(nom_estab, "ñ", "Ñ",.)
replace nom_estab = subinstr(nom_estab, "ã`", "Ñ",.)
replace nom_estab = subinstr(nom_estab, "á", "A",.)
replace nom_estab = subinstr(nom_estab, "é", "E",.)
replace nom_estab = subinstr(nom_estab, "í", "I",.)
replace nom_estab = subinstr(nom_estab, "ó", "O",.)
replace nom_estab = subinstr(nom_estab, "ú", "U",.)
replace nom_estab = subinstr(nom_estab, "ï", "I",.)
replace nom_estab = subinstr(nom_estab, "ü", "U",.)
replace nom_estab = subinstr(nom_estab, "ãš", "U",.)

replace nom_reg_estab = "REGIÓN DE TARAPACÁ" if nom_reg_estab == "REGIÓN DE TARAPACÁ "
* --- arreglar comuna
replace nom_com_estab = trim(nom_com_estab)
replace nom_com_estab = subinstr(nom_com_estab, "ñ", "Ñ",.)
replace nom_com_estab = subinstr(nom_com_estab, "ã`", "Ñ",.)
replace nom_com_estab = subinstr(nom_com_estab, "Á", "A",.)
replace nom_com_estab = subinstr(nom_com_estab, "É", "E",.)
replace nom_com_estab = subinstr(nom_com_estab, "Í", "I",.)
replace nom_com_estab = subinstr(nom_com_estab, "Ó", "O",.)
replace nom_com_estab = subinstr(nom_com_estab, "Ú", "U",.)
replace nom_com_estab = subinstr(nom_com_estab, "Ï", "I",.)
replace nom_com_estab = subinstr(nom_com_estab, "Ü", "U",.)
replace nom_com_estab = subinstr(nom_com_estab, "ãš", "U",.)

replace nom_com_estab = "CABO DE HORNOS" if nom_com_estab == "CABO DE HORNOS (EX - NAVARINO)"
replace nom_com_estab = "TREHUACO" if nom_com_estab == "TREGUACO"

rename (id_estab CORREOELECTRONICO DIRECCIONDELESTABLECIMIENTO DIRECTORAENCARGADOA LATITUD LONGITUD nom_com_estab) (institution_code email_junji address_junji director_junji lat_junji lon_junji geo_comuna_name)

gen dependencia = 7

label define dependencia 1 "Municipal" 2 "Particular Subvencionado" 3 "Particular Pagado" 4 "Corporación de Administración Delegada" 5 "Servicio Local de Educación" 6 "Sin Información" 7 "JUNJI" 8 "INTEGRA"
label values dependencia dependencia
decode dependencia, g(sector)

* --- arreglar lat lons
tostring lat_junji lon_junji, replace
replace lat_junji = subinstr(lat_junji,"0-","-",.)
*replace lon_junji = subinstr(lon_junji,"0-","-",.)
destring lat_junji lon_junji, replace

* --- arreglar telefonos
split TELEFONO, generate(phone2)
drop phone21 phone22 phone24 phone25 phone26
rename (phone27 phone23) (phone2_junji phone1_junji)

keep institution_code nom_estab sector email_junji address_junji director_junji lat_junji lon_junji phone1_junji phone2_junji geo_comuna_name
order institution_code nom_estab sector email_junji address_junji director_junji lat_junji lon_junji phone1_junji phone2_junji geo_comuna_name

count //3,193
tostring institution_code, replace

gen desde_junji = 1

tempfile contacto_junji
save `contacto_junji'

* ============================================================ *
* ====================== INFO DESDE INTEGRA ================== *
* ============================================================ *
import delimited "$pathDataExplorador/inputs/JARDINES/integra.csv", clear charset(utf8)
rename (codigo coord_latitud coord_longitud direccion nombre comuna correo telefono)(institution_code lat_integra lon_integra address_integra school_name geo_comuna_name email_integra phone_integra)
tostring institution_code, replace 
replace institution_code = institution_code+"I"
gen urban = (zona_urbana_rural=="URBANO")
keep institution_code school_name address_integra lat_integra lon_integra email_integra phone_integra geo_comuna_name

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

gen desde_integra = 1
gen dependencia = 8


label define dependencia 1 "Municipal" 2 "Particular Subvencionado" 3 "Particular Pagado" 4 "Corporación de Administración Delegada" 5 "Servicio Local de Educación" 6 "Sin Información" 7 "JUNJI" 8 "INTEGRA"
label values dependencia dependencia
decode dependencia, g(sector)
 
tempfile contacto_integra
save `contacto_integra', replace

* ============================================================= *
* ====================== MERGE INFO CONTACTO ================== *
* ============================================================= *
import delimited "$pathData/Output/Preview/supply_preview.csv", clear
gen edu_type = "Sin Información" if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
 
replace edu_type = "Sólo Párvulos"           if mat_parvularia > 0  & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Sólo Básica Niños"       if mat_parvularia == 0 &  mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Sólo Básica Adultos"     if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos > 0  & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Sólo Especial"           if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial > 0  & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Sólo Media Jóvenes"      if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0) & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Sólo Media Adultos"      if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  

replace edu_type = "Párvulos y Especial Niños"	     if mat_parvularia > 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Párvulos y Básica Niños" 		 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Párvulos y Media Jóvenes" 		 if mat_parvularia > 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0) & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Párvulos y Media Adultos" 		 if mat_parvularia > 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0)   

replace edu_type = "Párvulos, Básica Niños y Media Jóvenes"  if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 )& mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Párvulos, Básica Niños, Media Jóvenes y Especial"  if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 )& mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Párvulos, Básica Niños, Media Jóvenes y Media Adultos"  if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 ) & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0)   
replace edu_type = "Párvulos, Básica Niños y Especial"	 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   	
replace edu_type = "Párvulos, Básica Niños y Media Adultos"	 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  	
replace edu_type = "Párvulos, Básica Niños, Especial y Media Adultos"	 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  	
replace edu_type = "Párvulos, Básica Niños y Básica Adultos"	 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos > 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   	
replace edu_type = "Párvulos, Básica Niños, Básica Adultos y Especial"	 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos > 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   	
replace edu_type = "Párvulos, Básica Niños, Básica Adultos, Media Jóvenes y Media Adultos"	 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos > 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0) & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  	
replace edu_type = "Párvulos, Básica Niños, Básica Adultos y Media Adultos"	 if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos > 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  	
replace edu_type = "Párvulos, Especial y Media Jóvenes"	 if mat_parvularia > 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0) & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0 
replace edu_type = "Párvulos, Especial y Media Adultos"	 if mat_parvularia > 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  	

replace edu_type = "Párvulos, Básica Adultos y Media Adultos"  if mat_parvularia > 0 & mat_basica_ninios == 0 & mat_basica_adultos > 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0)   

replace edu_type = "Básica Niños Especial"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Básica Niños y Media Jóvenes"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 )& mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Básica Niños, Especial y Media Jóvenes"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 )& mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Básica Niños, Especial y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0 & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0   )
replace edu_type = "Básica Niños, Especial, Media Jóvenes y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 ) & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  
replace edu_type = "Básica Niños, Media Jóvenes y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 ) & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  
replace edu_type = "Básica Niños y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0  & (mat_media_tp_adultos == 0  | mat_media_ch_adultos == 0 )  
replace edu_type = "Básica Niños, Básica Adultos y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos > 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  
replace edu_type = "Básica Niños, Básica Adultos, Media Adultos y Media Jóvenes"  if mat_parvularia == 0 & mat_basica_ninios > 0 & mat_basica_adultos > 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0)  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  

replace edu_type = "Especial y Media Jóvenes"  if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0 )& mat_media_tp_adultos == 0  & mat_media_ch_adultos == 0   
replace edu_type = "Especial, Media Jóvenes y Media Adultos" if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0)  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  

replace edu_type = "Básica Adultos, Media Adultos y Media Jóvenes"  if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos > 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0)  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  
replace edu_type = "Básica Adultos y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos > 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  
replace edu_type = "Básica Adultos, Especial y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos > 0 & mat_especial > 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  

replace edu_type = "Básica Adultos y Media Adultos"  if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos > 0 & mat_especial == 0 & mat_media_tp_jovenes == 0 & mat_media_ch_jovenes == 0  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  
replace edu_type = "Media Jóvenes y Media Adultos" if mat_parvularia == 0 & mat_basica_ninios == 0 & mat_basica_adultos == 0 & mat_especial == 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0)  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  

replace edu_type = "Párvulos, todo Básica, todo Media, Especial" if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos > 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0)  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  
replace edu_type = "Párvulos, Básica Niños, todo Media, Especial" if mat_parvularia > 0 & mat_basica_ninios > 0 & mat_basica_adultos == 0 & mat_especial > 0 & (mat_media_tp_jovenes > 0 | mat_media_ch_jovenes > 0)  & (mat_media_tp_adultos > 0  | mat_media_ch_adultos > 0 )  

merge 1:m institution_code using `contacto_explorador'

/*
 Result                      Number of obs
    -----------------------------------------
    Not matched                         4,439
        from master                     4,432  (_merge==1)
        from using                          7  (_merge==2)

    Matched                            16,788  (_merge==3)
    -----------------------------------------

*/
drop _merge 

merge m:1 institution_code using `contacto_junji'
/*
 Result                      Number of obs
    -----------------------------------------
    Not matched                        18,094
        from master                    18,064  (_merge==1)
        from using                         30  (_merge==2)

    Matched                             3,163  (_merge==3)
    -----------------------------------------
*/
drop _merge 

merge m:1 institution_code using `contacto_integra'
/*
 Result                      Number of obs
    -----------------------------------------
    Not matched                        20,131
        from master                    20,129  (_merge==1)
        from using                          2  (_merge==2)

    Matched                             1,128  (_merge==3)
    -----------------------------------------
*/
drop _merge
* ---  reemplazar data 
replace email_ofprincipal = email_junji if email_ofprincipal ==""|email_ofprincipal =="@"
replace email_ofprincipal = email_integra if email_ofprincipal ==""|email_ofprincipal =="@"

replace name_director = director_junji if name_director == ""
replace address_street = address_junji if address_street == ""
replace address_street = address_integra if address_street == ""

replace school_name = nom_estab if school_name==""
replace latitud = lat_junji if latitud==.
replace longitud = lon_junji if longitud==.
replace latitud = lat_integra if latitud==.
replace longitud = lon_integra if longitud==.

destring phone1_junji phone2_junji, replace 
replace phone_ofprincipal =  phone_integra if phone_ofprincipal==.
replace phone_ofprincipal =  phone1_junji if phone_ofprincipal==.

rename cellphone_ofprincipal phone_ofprincipal2

replace phone_ofprincipal2 = phone2_junji if phone_ofprincipal2 ==.

format phone* %30.0f

drop geo_region* geo_provincia*
merge m:1 geo_comuna using "$pathData/codigos_geo.dta", update
 
keep institution_code campus_code school_name sector urban latitud longitud address_street geo* phone_ofprincipal* email_ofprincipal email_director name_director webpage* edu_type
order institution_code campus_code school_name sector urban latitud longitud address_street geo* phone_ofprincipal* email_ofprincipal email_director name_director webpage* edu_type

gen facebook = .
gen twitter = .
gen instagram = .

gen costo_matricula = .
gen costo_mensual = .
gen costo_incorporacion = .

gen phone_admision = .
gen email_admision = .

gen no_pagado =(sector!="Particular Pagado")

tempfile callcenter
save `callcenter',replace

* --- muestra solari 
import excel "$pathRandom/bases andrea_marcy/Muestra_solari_25042022.xlsx", clear first
keep institution_code
tostring institution_code,replace
merge 1:m institution_code using `callcenter'

gen solari_sample = (_merge==3)
drop _merge  
tostring campus_code, replace 


* --- campus_code artificial --- *
replace campus_code = institution_code+"00001" if campus_code=="."
duplicates report campus_code
duplicates report institution_code

* --- n_sede --- *
gen n_sede = substr(campus_code, -1,1)
gen unos=1
bys institution_code: egen n_tot_sede = count(1)
drop unos
sort institution_code campus_code
export delimited "$pathRandom/bases andrea_marcy/callcenter/para_callcenter.csv", replace 
