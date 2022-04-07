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
	global pathDataExplorador =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/Explorador_Chile/E_Escolar/"
  }

  if "`c(username)'"=="ij1376" { // Isa
    global pathData =  "C:/Users/ij1376/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile"
	global pathDataExplorador =  "C/Users/ij1376/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
  }
* ============================================================= *
* ================== LISTADO JARDINES PUBLICOS ================ *
* ============================================================= *
import excel "$pathData/Schools/Preescolar/ListadoJardinesPublicos_20220229163310.xls", sheet("JARDINES PUBLICOS") firstrow clear

gen origen = 1

tempfile municipales
save `municipales', replace

* ============================================================= *
* ================== LISTADO JARDINES PUBLICOS ================ *
* ============================================================= *
import excel "$pathData/Schools/Preescolar/ListadoJardinesPublicos_20220229163425.xls", clear firstrow
gen origen = 2
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
replace nom_estab = subinstr(nom_estab, "Ã", "Ñ",.)
replace nom_estab = subinstr(nom_estab, " - ", "-",.)
replace nom_estab = subinstr(nom_estab, "-", " ",.)
replace nom_estab = subinstr(nom_estab, "CASH ", "",.)
replace nom_estab = subinstr(nom_estab, "CECI ", "",.)
replace nom_estab = subinstr(nom_estab, "COIGUE", "COIHUE",.)
replace nom_estab = subinstr(nom_estab, "VILLA LOS ANDES DE CACHAPOAL", "VILLA LOS ANDES CACHAPOAL",.)
replace nom_estab = subinstr(nom_estab, "PEQUEÑAS SEMILLAS", "PEQUEÑAS SEMILLITAS",.)


tempfile junji_municipales
save `junji_municipales', replace //3,193

* ============================================================= *
* ==================== MATRICULA PREESCOLAR =================== *
* ============================================================= *
* --- base pública de matrícula preescolar
import delimited "$pathData/Schools/Preescolar/20211112_Educacion_parvularia_oficial_2021_20210831_WEB.csv", clear

* --- colapso a nivel de id_estab origen
collapse (firstnm) cod_ense1_m cod_ense2_m nom_estab nom_reg_a_estab nom_com_estab nom_pro_estab cod_depe1_m estado_estab_m id_estab_j id_estab_i rbd latitud longitud dependencia (mean) cod_reg_estab cod_pro_estab cod_com_estab rural_estab (count) matricula_preescolar = mrun , by(id_estab origen)

tempfile aux
save `aux'

* --- resumen de matricula preescolar
import delimited "$pathData/Schools/Preescolar/20211122_Resumen_Educacion_Parvularia_por_EE_2021_20210831.csv", clear
merge 1:1 id_estab origen using `aux', keepusing(latitud longitud dependencia cod_ense1_m cod_ense2_m)
drop _merge //deberían pegar todos

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
merge m:1 id_estab nom_estab using `junji_municipales', update //pegan 3163
rename _merge merge_listado_mineduc

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

keep id_estab nom_estab cod_ense cod_com_estab cod_pro_estab cod_reg_estab mat_nt2 mat_nt1 mat_med_may mat_sc_may mat_sc_men latitud longitud dependencia origen urban
/*agregar codigos a regiones con nombre y sin codigo */
*rename (rbd cod_region cod_pro_estab cod_comuna dependencia nom_estab nom_reg_a_estab nom_pro_estab nom_com_estab)(institution_code geo_region geo_provincia geo_comuna type_prek school_name geo_region_name geo_provincia_name geo_comuna_name)
duplicates tag id_estab origen, g(dup)
sort id_estab origen
br if dup>0

replace nom_estab = subinstr(nom_estab, "PMI ", "",.)
collapse (firstnm) urban mat_* latitud longitud cod_com_estab cod_pro_estab, by(id_estab nom_estab origen)

duplicates tag id_estab origen, g(dup)
sort id_estab origen

global aux_list1 " "4103012", "4301080", "4301881", "5703009", "6101015", "6104001", "6115003", "6301004", "7407012" "
global aux_list2 " "8201018", "9101096", "9101097", "9101100", "9102030", "9105033", "9112047", "9202010", "9205017" "
global aux_list3 " "12201004", "12301004", "13102019", "13106029", "13116018", "13121028", "13122058", "13124034" "
global aux_list4 " "13126021", "13303032", "13402037", "13601016" "

tostring id_estab, replace 
gen flag = 1 if dup>0
replace flag = . if inlist(id_estab,$aux_list1 ) | inlist(id_estab,$aux_list2 ) | inlist(id_estab,$aux_list3 ) | inlist(id_estab,$aux_list4 )
destring id_estab, replace 

sort id_estab origen mat_sc_men, stable 

bys id_estab origen: drop if dup>0 & flag == 1 & _n==1
br if dup>0

stop
//institution_code para aquellas instituciones que tienen id junji e integra (no tienen rbd)
gen institution_code_prek = id_estab
replace institution_code_prek = id_estab_i if origen == 3
replace institution_code_prek = id_estab_j if origen == 2

label define jardines 1 "Municipal" 2 "Subvencionado" 3 "Particular" 4 "JUNJI" 5 "INTEGRA" 6 "Servicio Local de Educación"
label values type_prek jardines

label define jardines1 1 "Municipal" 2 "JUNJI" 3 "INTEGRA"
label values origen jardines

gen db_origin = 2
gen preescolar = 1

tempfile jardines_mineduc
save `jardines_mineduc', replace
