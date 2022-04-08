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
  }

  if "`c(username)'"=="ij1376" { // Isa
    global pathData =  "C:/Users/ij1376/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile"
	global pathDataExplorador =  "C/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
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
collapse (firstnm)phone mail address dup dependencia sector_label_id nom_estab urban mat_* latitud longitud cod_com_estab cod_pro_estab cod_reg_estab, by(id_estab origen)

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

keep institution_code school_name type latitud longitud address phone_1 phone_2 mail

tempfile contact
save `contact'

* --- pegar info de jardines que ya tenemos 
import delimited "$pathDataExplorador/latest_from_back/cb_explorer_chile_institutions_contact.csv", clear 
keep if contact_label_id == 1
tostring institution_code, replace 
bys institution_code: keep if _n==1
merge 1:1 institution_code using `contact'
keep if _merge == 3
drop _merge //quiero los mismos que ya tengo, solo quiero completar la info (dsps agregar privados)
replace mail = email if mail==""
format phone %30.0g
destring phone* , replace
replace phone_1 = phone if phone_1 == .
replace phone_2 = cellphone if phone_2 == .

format phone_1 phone_2 %30.0g

tempfile junji
save `junji', replace 

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

keep if establecimiento == "Particular"
rename(nombre direccion)(school_name address)
keep school_name latitud longitud address phone_1 phone_2 


gen type = 3

append using `junji'
stop
export delimited "$pathDataExporador/inputs/contacto_jardines.csv", replace 

