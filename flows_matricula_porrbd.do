/*
================================================================================
FECHA CREACION: 2022-04-17
ULTIMA MODIFICACION: 2022-04-17 // ijacas
--------------------------------------------------------------------------------
PROYECTO: Tether
================================================================================
*/

/*
Identificar "transacciones" por colegio, es decir, todos los nuevos alumnos que
se matriculan cada año que significan una transacción en términos de digital
enrollment.
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

  if "`c(username)'"=="ijacas" { // Isa
    global pathData =  "C:/Users/ijacas/ConsiliumBots Dropbox/Schooling_Markets/Schooling_Markets_Chile"
  global pathDataExplorador =  "C:/Users/ijacas/ConsiliumBots Dropbox/Isabel Jacas/Exploradores/Explorador_Chile/E_Escolar/"
  global pathRandom = "C:/Users/ijacas/ConsiliumBots Dropbox/Isabel Jacas/data/"
  }




* ============================================================= *
* ========================== FLOWS MAT ======================== *
* ============================================================= *
/*
Tomaremos la matrícula por alumno para identificar alumnos que solo pasan
de curso y alumnos que se matrículan "nuevos" (sin importar su procedencia)
*/

import delimited "$pathRandom/input/Matricula-por-estudiante-2020/20200921_Matrícula_unica_2020_20200430_WEB.csv", clear delimiter(";") charset(utf8)
// tempfile mat2020
// save `mat2020'
// use `mat2020', clear

*--- Identificamos a los que tienen preschool y los que tienen 1ro basico
gen aux1 = cod_ense == 10
bysort rbd: egen preschool = max(aux1)
gen aux2 = cod_ense == 110 & cod_grado == 1
bysort rbd: egen primary = max(aux2)

drop aux1 aux2

keep if primary == 1 | preschool == 1
keep  mrun rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado primary preschool

tempfile mrun2020
save `mrun2020'


import delimited "$pathRandom/input/Matricula-por-estudiante-2021/20210913_Matrícula_unica_2021_20210430_WEB.csv", clear delimiter(";") charset(utf8)
// tempfile mat2021
// save `mat2021'
// use `mat2021', clear

*--- Identificamos a los que tienen preschool y los que tienen 1ro basico
gen aux1 = cod_ense == 10
bysort rbd: egen preschool = max(aux1)
gen aux2 = cod_ense == 110 & cod_grado == 1
bysort rbd: egen primary = max(aux2)

drop aux1 aux2

keep if primary == 1 | preschool == 1

keep  mrun rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado preschool primary
foreach x in rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado preschool primary{
  rename `x' `x'2021
}


merge 1:1 mrun using `mrun2020'

*-- Vemos quienes se mantienen de un año a otro, por nivel
gen samerbd = rbd2021 == rbd
gen diffrbd = rbd2021 != rbd
drop if rbd2021 == .


gen mat_total_2021 = 1
collapse (sum) samerbd diffrbd mat_total_2021, by(rbd2021 cod_reg_rbd2021 cod_com_rbd2021 cod_depe2021 cod_ense2021 cod_grado2021 preschool2021 primary2021)

*-- Eliminamos los colegios que abrieron en 2021
bysort rbd: egen sumsame = sum(samerbd)
drop if sumsame == 0
drop sumsame

*-- Eliminamos Ed Media
drop if cod_ense2021>300

*-- Identificamos los cursos nuevos o de entrada
gen entry = samerbd == 0

*-- Sumamos a nivel de RBD
bysort rbd: egen totmatnuevos = sum(diffrbd)
bysort rbd: egen totmatnuevos_noentry = sum(diffrbd) if entry == 0



collapse (max) totmatnuevos totmatnuevos_noentry (sum) mat_total_2021, by(rbd2021 cod_reg_rbd2021 cod_com_rbd2021 cod_depe2021 preschool2021 primary2021)

gen share = totmatnuevos/mat_total_2021
gen share_noentry = totmatnuevos_noentry/mat_total_2021

sum totmatnuevos if cod_reg_rbd2021 == 13, detail
sum share if cod_reg_rbd2021 == 13, detail
sum totmatnuevos_noentry, detail
sum share_noentry if cod_reg_rbd2021 == 13, detail

preserve
import delimited "$pathDataExplorador/inputs/2022_02_03/Listado_catdes2019_basica_MINEDUC_v21012020.csv", clear charset(utf8) delimiter(";")
tempfile catdes
save `catdes'
restore

rename rbd2021 rbd
merge 1:1 rbd using `catdes'
drop if _merge == 2
drop _merge



sum totmatnuevos if cod_reg_rbd2021 == 13 & categoria_des_num == 2, detail
sum share if cod_reg_rbd2021 == 13 & categoria_des_num == 2, detail
sum totmatnuevos_noentry & categoria_des_num == 1, detail
sum share_noentry if cod_reg_rbd2021 == 13 & categoria_des_num == 1, detail


save "$pathRandom/output/flows_mat_porrbd.dta", replace














* ============================================================= *
* ========================== FLOWS MAT ======================== *
* ============================================================= *
/*
Tomaremos la matrícula por alumno para identificar alumnos que solo pasan
de curso y alumnos que se matrículan "nuevos" (sin importar su procedencia)
*/

import delimited "$pathDataExplorador/input/Matricula-por-estudiante-2020/20200921_Matrícula_unica_2020_20200430_WEB.csv", clear delimiter(";") charset(utf8)
// tempfile mat2020
// save `mat2020'
// use `mat2020', clear

*--- Identificamos a los que tienen preschool y los que tienen 1ro basico
gen aux1 = cod_ense == 10
bysort rbd: egen preschool = max(aux1)
gen aux2 = cod_ense == 110 & cod_grado == 1
bysort rbd: egen primary = max(aux2)

drop aux1 aux2

keep if primary == 1 | preschool == 1
keep  mrun rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado primary preschool

tempfile mrun2020
save `mrun2020'


import delimited "$pathRandom/input/Matricula-por-estudiante-2021/20210913_Matrícula_unica_2021_20210430_WEB.csv", clear delimiter(";") charset(utf8)
// tempfile mat2021
// save `mat2021'
// use `mat2021', clear

*--- Identificamos a los que tienen preschool y los que tienen 1ro basico
gen aux1 = cod_ense == 10
bysort rbd: egen preschool = max(aux1)
gen aux2 = cod_ense == 110 & cod_grado == 1
bysort rbd: egen primary = max(aux2)

drop aux1 aux2

keep if primary == 1 | preschool == 1

keep  mrun rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado preschool primary
foreach x in rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado preschool primary{
  rename `x' `x'2021
}


merge 1:1 mrun using `mrun2020'

*-- Vemos quienes se mantienen de un año a otro, por nivel
gen samerbd = rbd2021 == rbd
gen diffrbd = rbd2021 != rbd
drop if rbd2021 == .


gen mat_total_2021 = 1
collapse (sum) samerbd diffrbd mat_total_2021, by(rbd2021 cod_reg_rbd2021 cod_com_rbd2021 cod_depe2021 cod_ense2021 cod_grado2021 preschool2021 primary2021)

*-- Eliminamos los colegios que abrieron en 2021
bysort rbd: egen sumsame = sum(samerbd)
drop if sumsame == 0
drop sumsame

*-- Eliminamos Ed Media
drop if cod_ense2021>300

*-- Identificamos los cursos nuevos o de entrada
gen entry = samerbd == 0

tempfile aquiaqui1
save `aquiaqui1'

*-- Sumamos a nivel de RBD
bysort rbd: egen totmatnuevos = sum(diffrbd)
bysort rbd: egen totmatnuevos_noentry = sum(diffrbd) if entry == 0



collapse (max) totmatnuevos totmatnuevos_noentry (sum) mat_total_2021, by(rbd2021 cod_reg_rbd2021 cod_com_rbd2021 cod_depe2021 preschool2021 primary2021)
egen tot = sum(totmatnuevos)
egen totnotentry = sum(totmatnuevos_noentry)
egen mattot = sum(mat_total_2021)
gen share = totmatnuevos/mat_total_2021
gen share_noentry = totmatnuevos_noentry/mat_total_2021

sum totmatnuevos if cod_reg_rbd2021 == 13, detail
sum share if cod_reg_rbd2021 == 13, detail
sum totmatnuevos_noentry, detail
sum share_noentry if cod_reg_rbd2021 == 13, detail

preserve
import delimited "$pathDataExplorador/inputs/2022_02_03/Listado_catdes2019_basica_MINEDUC_v21012020.csv", clear charset(utf8) delimiter(";")
tempfile catdes
save `catdes'
restore

rename rbd2021 rbd
merge 1:1 rbd using `catdes'
drop if _merge == 2
drop _merge



sum totmatnuevos if cod_reg_rbd2021 == 13 & categoria_des_num == 2, detail
sum share if cod_reg_rbd2021 == 13 & categoria_des_num == 2, detail
sum totmatnuevos_noentry & categoria_des_num == 1, detail
sum share_noentry if cod_reg_rbd2021 == 13 & categoria_des_num == 1, detail


save "$pathRandom/output/flows_mat_porrbd.dta", replace
use "$pathRandom/output/flows_mat_porrbd.dta", clear










import delimited "$pathRandom/input/Matricula-por-estudiante-2018/20181005_Matrícula_unica_2018_20180430_PUBL.csv", clear delimiter(";") charset(utf8)
tempfile mat2018
save `mat2018'
// use `mat2018', clear

*--- Identificamos a los que tienen preschool y los que tienen 1ro basico
gen aux1 = cod_ense == 10
bysort rbd: egen preschool = max(aux1)
gen aux2 = cod_ense == 110 & cod_grado == 1
bysort rbd: egen primary = max(aux2)

drop aux1 aux2

keep if primary == 1 | preschool == 1
keep  mrun rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado primary preschool

tempfile mrun2018
save `mrun2018'



import delimited "$pathRandom/input/Matricula-por-estudiante-2019/20191028_Matrícula_unica_2019_20190430_PUBL.csv", clear delimiter(";") charset(utf8)
// tempfile mat2019
// save `mat2019'
// use `mat2019', clear

*--- Identificamos a los que tienen preschool y los que tienen 1ro basico
gen aux1 = cod_ense == 10
bysort rbd: egen preschool = max(aux1)
gen aux2 = cod_ense == 110 & cod_grado == 1
bysort rbd: egen primary = max(aux2)

drop aux1 aux2

keep if primary == 1 | preschool == 1

keep  mrun rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado preschool primary
foreach x in rbd cod_reg_rbd cod_com_rbd cod_depe rural_rbd cod_ense cod_grado preschool primary{
  rename `x' `x'2019
}

merge 1:1 mrun using `mrun2018'

*-- Vemos quienes se mantienen de un año a otro, por nivel
gen samerbd = rbd2019 == rbd
gen diffrbd = rbd2019 != rbd
drop if rbd2019 == .


gen mat_total_2019 = 1
collapse (sum) samerbd diffrbd mat_total_2019, by(rbd2019 cod_reg_rbd2019 cod_com_rbd2019 cod_depe2019 cod_ense2019 cod_grado2019 preschool2019 primary2019)

*-- Eliminamos los colegios que abrieron en 2021
bysort rbd: egen sumsame = sum(samerbd)
drop if sumsame == 0
drop sumsame

*-- Eliminamos Ed Media
tempfile aqui
save `aqui'
drop if cod_ense2019>300

*-- Identificamos los cursos nuevos o de entrada
gen entry = samerbd == 0

*-- Sumamos a nivel de RBD
bysort rbd: egen totmatnuevos = sum(diffrbd)
bysort rbd: egen totmatnuevos_noentry = sum(diffrbd) if entry == 0



collapse (max) totmatnuevos totmatnuevos_noentry (sum) mat_total_2019, by(rbd2019 cod_reg_rbd2019 cod_com_rbd2019 cod_depe2019 preschool2019 primary2019)

gen share = totmatnuevos/mat_total_2019
gen share_noentry = totmatnuevos_noentry/mat_total_2019

sum totmatnuevos if cod_reg_rbd2019 == 13, detail
sum share if cod_reg_rbd2019 == 13, detail
sum totmatnuevos_noentry if cod_reg_rbd2019 == 13, detail
sum share_noentry if cod_reg_rbd2019 == 13, detail

save "$pathRandom/output/flows_mat_porrbd_precovid.dta", replace














import delimited "$pathDataExplorador/inputs/2022_02_03/Directorio-Docentes-2020/20200727_Docentes_2020_20200630_PUBL.csv", clear delimiter(";") charset(utf8)
// tempfile doc2020
// save `doc2020'
// use `doc2020', clear

keep  mrun rbd cod_reg_rbd cod_depe
// duplicates report mrun
// bysort mrun: gen n = _n
// reshape wide rbd cod_reg_rbd cod_depe, i(mrun) j(n)

tempfile mrundoc2020
save `mrundoc2020'



import delimited "$pathDataExplorador/inputs/2022_02_03/20210727_Docentes_2021_20210630_PUBL.csv", clear delimiter(";") charset(utf8)
// tempfile doc2021
// save `doc2021'
// use `doc2021', clear

keep  mrun rbd cod_reg_rbd cod_depe
// duplicates report mrun
// bysort mrun: gen n = _n
// reshape wide rbd cod_reg_rbd cod_depe, i(mrun) j(n)
//
//
// foreach x in rbd1 cod_reg_rbd1 cod_depe1 rbd2 cod_reg_rbd2 cod_depe2 rbd3 cod_reg_rbd3 cod_depe3 rbd4 cod_reg_rbd4 cod_depe4 rbd5 cod_reg_rbd5 cod_depe5 rbd6 cod_reg_rbd6 cod_depe6 rbd7 cod_reg_rbd7 cod_depe7 rbd8 cod_reg_rbd8 cod_depe8 rbd9 cod_reg_rbd9 cod_depe9 rbd10 cod_reg_rbd10 cod_depe10 rbd11 cod_reg_rbd11 cod_depe11 rbd12 cod_reg_rbd12 cod_depe12 rbd13 cod_reg_rbd13 cod_depe13 {
//   rename `x' `x'_2021
// }

merge 1:1 mrun rbd using `mrundoc2020'
drop if _merge == 2
gen nuevo = _merge == 1
gen total = 1
collapse (sum) total nuevo, by(rbd cod_reg_rbd)

gen share = nuevo/total

sum nuevo if cod_reg_rbd == 13, detail
sum share if cod_reg_rbd == 13, detail
egen sumtot = sum(total)
egen sumnuevos = sum(nuevo)

save "$pathRandom/output/flows_docentes.dta", replace










import delimited "$pathDataExplorador/inputs/2022_02_03/Directorio-Docentes-2018/20180807_Docentes_2018_20180630_WEB.csv", clear delimiter(";") charset(utf8)
// tempfile doc2018
// save `doc2018'
// use `doc2018', clear

keep  mrun rbd cod_reg_rbd cod_depe
tempfile mrundoc2018
save `mrundoc2018'



import delimited "$pathDataExplorador/inputs/2022_02_03/Directorio-Docentes-2019/20191009_Docentes_2019_20190630_PUBL.csv", clear delimiter(";") charset(utf8)
// tempfile doc2019
// save `doc2019'
// use `doc2019', clear

keep  mrun rbd cod_reg_rbd cod_depe

merge 1:1 mrun rbd using `mrundoc2018'
drop if _merge == 2
gen nuevo = _merge == 1
gen total = 1
collapse (sum) total nuevo, by(rbd cod_reg_rbd)

gen share = nuevo/total

sum nuevo if cod_reg_rbd == 13, detail
sum share if cod_reg_rbd == 13, detail
egen sumtot = sum(total)
egen sumnuevos = sum(nuevo)

save "$pathRandom/output/flows_docentes_precovid.dta", replace
