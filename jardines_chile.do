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
keep id_estab nom_estab cod_ense cod_com_estab cod_pro_estab cod_reg_estab mat_nt2 mat_nt1 mat_med_may mat_sc_may mat_sc_men latitud longitud dependencia origen urban
/*agregar codigos a regiones con nombre y sin codigo */
*rename (rbd cod_region cod_pro_estab cod_comuna dependencia nom_estab nom_reg_a_estab nom_pro_estab nom_com_estab)(institution_code geo_region geo_provincia geo_comuna type_prek school_name geo_region_name geo_provincia_name geo_comuna_name)
duplicates tag id_estab origen, g(dup)
sort id_estab origen
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
