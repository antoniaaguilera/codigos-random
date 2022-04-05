
/*
flag:
1 if don't apply 
2 apply through sae
3 enroll in other school (not sae)
4 changed schools not sae 
5 come from same school 
*/
global path =  "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/data"

* ------------------------------------------------ *
* ---------------- MATRICULA 2020 ---------------- *
* ------------------------------------------------ *
import delimited "$path/input/Matricula-por-estudiante-2020/20200921_Matrícula_unica_2020_20200430_WEB.CSV", clear
rename rbd rbd_2020
keep if  cod_ense==10 |cod_ense==110 | cod_ense == 310 | cod_ense == 410 | cod_ense == 510 | cod_ense == 610 | cod_ense ==710 | cod_ense ==810 |cod_ense ==910
keep if cod_depe2!= 3


save "$path/intermedias/matricula_2020.dta", replace 

* ------------------------------------------------------ *
* ---------------- POSTULANTES SAE 2020 ---------------- *
* ------------------------------------------------------ *

import delimited "$path/input/SAE 2020/B1_Postulantes_etapa_regular_2020_Admisión_2021_PUBL.csv", clear 

tempfile postulantes_reg 
save `postulantes_reg', replace 

import delimited "$path/input/SAE 2020/B2_Postulantes_etapa_complementaria_2020_Admisión_2021_PUBL.csv", clear 

append using `postulantes_reg'

bys mrun: keep if _n==1

save "$path/intermedias/postulantes.dta", replace 

* ---------------------------------------------------- *
* ---------------- REPUESTAS SAE 2020 ---------------- *
* ---------------------------------------------------- *
import delimited "$path/input/SAE 2020/D1_Resultados_etapa_regular_2020_Admisión_2021_PUBL.csv", clear
gen etapa = "reg"
tempfile respuestas_reg
save `respuestas_reg'

import delimited "$path/input/SAE 2020/D2_Resultados_etapa_complementaria_2020_Admisión_2021_PUBL.csv", clear
gen etapa = "comp"

append using `respuestas_reg'

duplicates tag mrun, g(dup)
drop if dup>0 & etapa=="reg"

gen rbd = ""
replace rbd = rbd_admitido_post_resp
replace rbd = rbd_admitido if rbd==" "

gen cod_curso_sae = cod_curso_admitido_post_resp
replace cod_curso_sae = cod_curso_admitido_post_resp if cod_curso_sae==""
destring respuesta*, replace 

drop rbd_admitido_post_resp rbd_admitido

label define respuestas 1 "ACEPTA" 2 "ACEPTA Y ESPERA" 3 "RECHAZA" 4 "RECHAZA Y ESPERA" 5 "SIN RESPUESTA" 6 "SIN ASIGNACION" 7 "SALE DEL PROCESO"
label values respuesta_postulante respuestas
label values respuesta_postulante_post_lista_ respuestas

destring rbd, replace 
save "$path/intermedias/respuestas.dta", replace //493,710

* ------------------------------------------------ *
* ---------------- MATRICULA 2021 ---------------- *
* ------------------------------------------------ *
import delimited "$path/input/Matricula-por-estudiante-2021/20210913_Matrícula_unica_2021_20210430_WEB.CSV", clear
rename rbd rbd_2021
keep if cod_ense==10 |cod_ense==110 | cod_ense == 310 | cod_ense == 410 | cod_ense == 510 | cod_ense == 610 | cod_ense ==710 | cod_ense ==810 |cod_ense ==910
keep if cod_depe2!= 3
rename (cod_ense cod_grado)(cod_ense_2021 cod_grado_2021)
save "$path/intermedias/matricula_2021.dta", replace 


* ------------------------------------------------ *
* ----------------- GENERAR STATS ---------------- *
* ------------------------------------------------ *

* --- POSTULANTES + RESPUESTAS 
use "$path/intermedias/postulantes.dta", clear
merge 1:1 mrun using "$path/intermedias/respuestas.dta"
drop _merge 
collapse (count) mrun
gen tipo = "Applies through SAE - All"
append using "$path/output/flows_mat.dta"
save "$path/output/flows_mat.dta", replace 

* ---  MATRICULAS
use "$path/intermedias/matricula_2020", clear 
drop if cod_grado==4 & cod_ense >=310
preserve 
collapse (count) mrun
gen tipo = "Enrollment in 2020"
save "$path/output/flows_mat.dta", replace 
restore 

rename (cod_ense cod_grado) (cod_ense_2020 cod_grado_2020)
merge 1:1 mrun using "$path/intermedias/matricula_2021.dta", gen(merge_matricula)
merge 1:1 mrun using "$path/intermedias/postulantes.dta", gen(merge_sae)

gen tipo = ""
replace tipo = "Dropouts" 							if merge_matricula == 1 & merge_sae ==1
replace tipo = "Applies through SAE - Dropouts" 	if merge_matricula == 1 & merge_sae ==3
replace tipo = "Not SAE - New Students" 			if merge_matricula == 2 & merge_sae == 1
replace tipo = "Applies through SAE - New Students" if merge_matricula == 2 & merge_sae == 3
replace tipo = "Applies through SAE - Diff School"  if merge_matricula == 3 & merge_sae == 3 & (rbd_2020!=rbd_2021)
replace tipo = "Applies through SAE - Same School" 	if merge_matricula == 3 & merge_sae == 3 & (rbd_2020==rbd_2021)
replace tipo = "Don't Apply - Enroll Same School"   if merge_matricula == 3 & merge_sae == 1 & (rbd_2020==rbd_2021)
replace tipo = "Don't Apply - Enroll Diff School" 	if merge_matricula == 3 & merge_sae == 1 & (rbd_2020!=rbd_2021)

drop if tipo==""

collapse (count) mrun , by(tipo)
append using "$path/output/flows_mat.dta"
expand 2 in 9
replace tipo="Enrollment in 2021" if _n==10
replace mrun = mrun[8]+mrun[3]+mrun[1]+mrun[4]+mrun[5]+mrun[6] if _n==10

save "$path/output/flows_mat.dta", replace 


* ---------------------------------------- *
* ---------------- IGNORE ---------------- *
* ---------------------------------------- *
* ------- OLD CODE 

* --- matricula 2021+matricula 2020; same school 
use "$path/intermedias/matricula_2020", clear 
drop if cod_grado==4 & cod_ense >=310
merge 1:1 mrun using "$path/intermedias/matricula_2021"
keep if _merge == 3 
drop _merge 
merge 1:1 mrun using "$path/intermedias/postulantes.dta"
keep if rbd_2021==rbd_2020 
drop if _merge == 2
collapse (count) mrun, by(_merge)

gen tipo = "Same School no SAE" if _merge ==1 
replace tipo = "Same School SAE" if _merge ==3
append using "$path/output/flows_mat.dta"
save "$path/output/flows_mat.dta", replace 

* --- matricula 2021+matricula 2020; diff school 
use "$path/intermedias/matricula_2020", clear 
drop if cod_grado==4 & cod_ense >=310
merge 1:1 mrun using "$path/intermedias/matricula_2021"
keep if _merge == 3 
drop _merge 
merge 1:1 mrun using "$path/intermedias/postulantes.dta"
keep if _merge == 1 & (rbd_2020!=rbd_2021)
collapse (count) mrun
gen tipo = "Changed school not sae"
append using "$path/output/flows_mat.dta"
save "$path/output/flows_mat.dta", replace 

* --- matricula 2021+matricula 2020; enrolls in assigned school
use "$path/intermedias/matricula_2020", clear 
drop if cod_grado==4 & cod_ense >=310
merge 1:1 mrun using "$path/intermedias/matricula_2021"
keep if _merge == 3 
drop _merge 
merge 1:1 mrun using "$path/intermedias/respuestas.dta"
keep if _merge == 3
gen flag= 1 if _merge == 3 & (rbd_2021==rbd)
replace flag= 2 if _merge == 3 & (rbd_2021!=rbd)
collapse (count) mrun, by(flag)
gen tipo = "Come from sae" if flag == 1
replace tipo = "Come from SAE Don't enroll in assignment" if flag== 2
append using "$path/output/flows_mat.dta"
drop flag _merge
save "$path/output/flows_mat.dta", replace 

stop 

* ---------------------------------------- *
* ---------------- IGNORE ---------------- *
* ---------------------------------------- *
* ------- OLD CODE 

import delimited "$path/input/Rendimiento-2020/20210223_Rendimiento_2020_20210131_WEB.csv", clear
*tab sit_fin
*duplicates report mrun

gen sitfin=1
replace sitfin=2 if sit_fin_r=="Y"
replace sitfin=3 if sit_fin_r=="R"
replace sitfin=4 if sit_fin_r=="P"
replace sitfin=. if sit_fin_r==""
label define Sitfin 1 "Trasladado" 2 "Retirado" 3 "Reprobado" 4 "Promovido"
label values sitfin Sitfin
bys mrun: egen sitfinal=max(sitfin)
label values sitfinal Sitfin
tab sitfinal
gen aux=rbd if sitfinal==sitfin
bys mrun: egen rbd_sitfinal=max(aux)
sort mrun
%browse mrun rbd sitfinal sitfin rbd_sitfinal
* - crear dummy para identificar traslados
gen aux_sitfin     = 1  if sitfin == 1
replace aux_sitfin = 1  if sitfin == 2
bys mrun : egen cambia_rbd = max(aux_sitfin) //terminan el año en un rbd diferente del que inician
tab cambia_rbd
keep if cod_ense==110 | cod_ense == 310 | cod_ense == 410 | cod_ense == 510 | cod_ense == 610 | cod_ense ==710 | cod_ense ==810 |cod_ense ==910
*collapse (count) mrun, by(rbd sitfin)
rename (rbd rbd_sitfinal cod_ense cod_grado) (rbd_inicial2020 rbd_final2020 cod_ense_2020sitfin cod_grado_2020sitfin)
save "$path/intermedias/sitfin_byrbd.dta", replace


import delimited "$path/input/Matricula-por-estudiante-2021/20210913_Matrícula_unica_2021_20210430_WEB.CSV", clear
keep if cod_ense == 10 | cod_ense==110 | cod_ense == 310 | cod_ense == 410 | cod_ense == 510 | cod_ense == 610 | cod_ense ==710 | cod_ense ==810 |cod_ense ==910
rename (rbd cod_ense cod_grado) (rbd_2021 cod_ense_2021 cod_grado_2021)
save "$path/intermedias/matricula_2021.dta", replace

import delimited "$path/input/Matricula-por-estudiante-2020/20200921_Matrícula_unica_2020_20200430_WEB.CSV", clear
keep if cod_ense == 10 | cod_ense==110 | cod_ense == 310 | cod_ense == 410 | cod_ense == 510 | cod_ense == 610 | cod_ense ==710 | cod_ense ==810 |cod_ense ==910
rename (rbd cod_ense cod_grado) (rbd_2020 cod_ense_2020 cod_grado_2020)

merge 1:1 mrun using "$path/intermedias/matricula_2021.dta"
keep mrun agno rbd* cod_ense* cod_grado* _merge
rename _merge merge_mat

merge 1:m mrun using "$path/intermedias/sitfin_byrbd.dta"
drop if _merge == 2
keep mrun rbd* sitfin cod_ense_20* cod_grado_20*  sitfin sitfinal _merge merge_mat
order mrun rbd* sitfin cod_ense* cod_grado*   sitfinal
sort mrun
* --- botar 4tos medios que fueron promovidos el 2020 y no van a estar el 2021
drop if cod_ense_2020>=310&cod_grado_2020==4 & sitfin==4

* --- identificar la muestra
gen flag = 1     if rbd_2020 != rbd_2021  //todos los estudiantes dentro del sistema que cambian de rbd a fines de 2020
replace flag = 2 if sitfin <=2  //todos los que estaban en el sistema en 2020 que se cambian a mitad de año y buscan colegio en 2020
replace flag = 3 if merge_mat == 2 & cod_ense_2021 == 10
replace flag = 4 if merge_mat == 2 & cod_ense_2021 != 10

drop if flag == .
collapse (count) mrun , by(flag)
%browse
