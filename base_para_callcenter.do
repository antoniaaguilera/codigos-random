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
/*
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
*/

* =============================================== *
* ==================== ARREGLOS ================= *
* =============================================== *
import delimited  "$pathFromBack/cb_explorer_chile_institutions_campus.csv", clear charset(utf8)
tostring institution_code campus_code, replace 
tempfile aux 
save `aux', replace 

import excel "$pathRandom/bases andrea_marcy/callcenter/para_callcenter_20220519.xlsx", clear first
*ver duplicados por nombre
replace school_name = ustrtitle(school_name)
merge 1:1 campus_code using `aux', keepusing(institution_code)

duplicates tag school_name n_sede geo_region geo_comuna, g(dup)
sort school_name geo_comuna geo_region 
br campus_code institution_code school_name geo* _merge if dup>0

* cuantos duplicados hay 
gen codigo_parvulo = institution_code if dup==1 & _merge == 1
sort school_name geo_comuna geo_region n_sede codigo_parvulo
bys school_name geo_comuna geo_region n_sede: replace codigo_parvulo = codigo_parvulo[_n+1] if _n==1

bys school_name geo_comuna geo_region n_sede: replace sector = sector[_n+1] if _n==1
bys school_name geo_comuna geo_region n_sede: replace urban = urban[_n+1] if _n==1

* flag los que hay que ir botando 
bys school_name n_sede geo_region geo_comuna: gen flag = 1 if _merge==1&dup==1
drop if flag == 1

* cuantos duplicados quedan
duplicates report school_name n_sede geo_comuna geo_region
/*
--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |        17071             0
        2 |           82            41
        4 |            4             3
       16 |           16            15
--------------------------------------
*/

* cuantos duplicados quedan
duplicates tag school_name n_sede latitud longitud, g(dup2)
br campus_code institution_code school_name geo* _merge latitud longitud if dup2==1 //sólo puedo arreglar cuando hay 1 duplicado (un rbd y un codigo parvulo)

replace codigo_parvulo = institution_code if dup2==1 &_merge==1&latitud!=.

gsort school_name geo_comuna geo_region n_sede latitud longitud codigo_parvulo -_merge
bys school_name geo_comuna geo_region n_sede: replace codigo_parvulo = codigo_parvulo[_n+1] if dup2>0 & codigo_parvulo==""

bys school_name geo_comuna geo_region n_sede: replace sector = sector[_n+1] if _n==1
bys school_name geo_comuna geo_region n_sede: replace urban = urban[_n+1] if _n==1
bys school_name geo_comuna geo_region n_sede: replace phone_ofprincipal = phone_ofprincipal[_n+1] if _n==1

* flag los que hay que ir botando 
bys school_name n_sede geo_region geo_comuna: replace flag = 1 if _merge==1&dup2==1
drop if flag == 1
 
drop _merge flag
gen updated_withdup = . 
foreach codigo in 10207001 11201050 13102019 13106021 13106028 13108003 13110026 13110030 13111021 13112032 13118006 13121022 13121028 13122017 13124034 13201088 13301049 13302016 13501035 {
	replace updated_withdup = 1 if codigo_parvulo=="`codigo'"
	}
gen updated_nodup = .
foreach codigo in 10207001 11201050 13102019 13106021 13106028 13108003 13110026 13110030 13111021 13112032 13118006 13121022 13121028 13122017 13124034 13201088 13301049 13302016 13501035 {
	replace updated_nodup = 1 if institution_code=="`codigo'"&updated_withdup==.
	}
	
export excel "$pathRandom/bases andrea_marcy/callcenter/para_callcenter_20220530.xlsx", replace first(var)
 
keep institution_code campus_code codigo_parvulo school_name geo_region_name geo_comuna_name
 
 
* --- casos especiales (que voy arreglando a medida que voy haciendo los updates )
replace codigo_parvulo = "13102019" if institution_code == "41404" //manutara
replace codigo_parvulo = "13118006" if institution_code == "35618" //reina de la paz
replace codigo_parvulo = "13121028" if institution_code == "34531" //salvador allende
replace codigo_parvulo = "13301049" if institution_code == "32028" //sembrando sueños 
replace codigo_parvulo = "13124034" if institution_code == "41785" //Awka Pillmayken
replace codigo_parvulo = "13106028" if institution_code == "41434" //coyhaique estación central
replace codigo_parvulo = "13501061" if institution_code == "36051" //sonrisitas melipilla
replace codigo_parvulo = "13603010" if institution_code == "36104" //harawy isla de maipo
replace codigo_parvulo = "10101064" if institution_code == "35110" //Ayekantun puerto montt
replace codigo_parvulo = "13105014" if institution_code == "35448" //mis primeros pasos el bosque 
replace codigo_parvulo = "13107013" if institution_code == "31354" //rayito de luna huechuraba 
replace codigo_parvulo = "13110045" if institution_code == "41441" //puerto eden la florida 
replace codigo_parvulo = "13116019" if institution_code == "32072" //munay lo espejo 
replace codigo_parvulo = "13125025" if institution_code == "32076" //renaciendo sueños quilicura 
replace codigo_parvulo = "13404039" if institution_code == "41886" //las lilas paine 

keep if codigo_parvulo!=""
drop if school_name==""
rename institution_code rbd
save "$pathDataExplorador/inputs/Hunters/crosswalk_rbd_jardines.dta", replace 

/*
buscar _merge==2 y hacer calzar nombre y comuna, si
solo hay 2 EE, es ese, reemplazar institution_code

*/






