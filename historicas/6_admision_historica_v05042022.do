
* ================================================================================
* FECHA CREACION: 2021-03-01
* ULTIMA MODIFICACION: 2022-03-01 // akac
* --------------------------------------------------------------------------------
* PROYECTO: Explorador Chile
* DESCRIPCIÓN: Este código arma la sección histórica de admisión del explorador
* ================================================================================


global year=2022

global fecha_outputs_old = "2022_02_03"

* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
* PREAMBULO
* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
global pathBack = "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/latest_from_back"
* --------------------------------------------------------------------------------
* Crear program_ids
* --------------------------------------------------------------------------------

* -- specialty codes
import delimited "$pathBack/cb_explorer_chile_institutions_specialty_label.csv", clear delimiter(",") charset(utf8)
*cod_espe
rename id specialty_label_id
tempfile specialty
save `specialty', replace 

* -- modality codes
import delimited "$pathBack/cb_explorer_chile_institutions_modality_codes_label.csv", clear delimiter(",") charset(utf8)
*id, cod_grado, cod_ense y modality_label_id
tempfile modality
save `modality', replace 

* -- gradetrack
import delimited "$pathBack/cb_explorer_chile_institutions_grade_track.csv", clear delimiter(",") charset(utf8)
rename id gradetrack_id
tempfile grade_track
save `grade_track', replace 

* -- program
import delimited "$pathBack/cb_explorer_chile_institutions_program.csv", clear delimiter(",") charset(utf8)

rename id program_id 
tempfile programid
save `programid', replace 

* -- pegar para recuperar cod_ense y cod_grado 
merge m:1 gradetrack_id using `grade_track'
keep if _merge == 3
drop _merge

* -- pegar para recuperar modality_label_id
merge m:1 modality_label_id using `modality'
keep if _merge == 3
drop _merge

* -- pegar para recuperar cod_espe
merge m:1 specialty_label_id using `specialty'
keep if _merge == 3
drop _merge 

replace year = $year

keep campus_code gender_id gradetrack_id institution_code shift_label_id academy_id grade_label_id modality_label_id specialty_label_id stage_label_id cod_grado cod_ense specialty_code program_id

* ---- construir cod_curso 
* -- recuperar cod_ense y cod_grado (están al reves)
rename (cod_ense cod_grado)(cod_grado cod_ense)
tostring cod_ense cod_grado, replace 
replace cod_ense = "0"+cod_ense if cod_ense == "10"
gen len=length(cod_ense)
tab len 
drop len

* -- cod_espe
tostring specialty_code, replace 
gen len_specialty = length(specialty_code)
tab len_specialty
replace specialty_code = "0000"+specialty_code if len_specialty == 1
rename specialty_code cod_espe

* -- cod_sede, cod_genero, cod_jor 
rename (academy_id gender_id shift_label_id)(cod_sede cod_genero cod_jor)
tostring cod_sede cod_genero cod_jor, replace 

* --- generar cod_curso
gen cod_curso = cod_grado+cod_ense+cod_espe+cod_sede+cod_genero+cod_jor
gen len_curso=length(cod_curso)
tab len_curso //solo pueden haber de 12 y 13 digitos

destring cod_curso cod_genero cod_jor , replace 
format cod_curso campus_code %30.0g

rename (cod_genero cod_jor)(gender_label_id shift_label_id)

keep institution_code campus_code program_id gradetrack_id cod_curso gender_label_id shift_label_id

tempfile programid
save `programid', replace 

* --------------------------------------------------------------------------------
* TRAER TABLAS DEL MODELO BASE
* --------------------------------------------------------------------------------

/*
{
* -- PROGRAMS
import delimited "$pathBack/cb_explorer_chile_institutions_program.csv", clear delimiter(",") charset(utf8)
replace year = $year
keep id year campus_code gender_id gradetrack_id institution_code shift_label_id regular_vacancies special_1_vacancies academy_id boolean_vacancies

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_program_historic.csv", replace

* -- GRADE TRACK
import delimited "$pathBack/cb_explorer_chile_institutions_grade_track.csv", clear delimiter(",") charset(utf8)
replace year = $year
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_grade_track_historic.csv", replace

* -- CAMPUS
import delimited "$pathBack/cb_explorer_chile_institutions_campus.csv", clear delimiter(",") charset(utf8)
replace year = $year
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_campus_historic.csv", replace

* -- SHIFT LABEL
import delimited "$pathBack/cb_explorer_chile_institutions_shift_label.csv", clear delimiter(",") charset(utf8)
replace year = $year
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_shift_label_historic.csv", replace

* -- GENDER LABEL
import delimited "$pathBack/cb_explorer_chile_institutions_gender_label.csv", clear delimiter(",") charset(utf8)
replace year = $year
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_gender_label_historic.csv", replace

* -- ADMISSION SYSTEM 
import delimited "$pathBack/cb_explorer_chile_institutions_admission_system.csv", clear delimiter(",") charset(utf8)
replace year = $year
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_admission_system_historic.csv", replace

* -- ADMISSION SYSTEM LABEL
import delimited "$pathBack/cb_explorer_chile_institutions_admission_system_label.csv", clear delimiter(",") charset(utf8)
gen year=$year
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_admission_system_label_historic.csv", replace

* -- LOCATION
import delimited "$pathBack/cb_explorer_chile_institutions_location.csv", clear delimiter(",") charset(utf8)
gen year=$year
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_location_historic.csv", replace

}
*/

* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
* GENERAR IDS UNICOS PARA EL MODELO HISTORICO
* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
/*
{
* SAE 2022: ronda 1
import delimited "$pathData/inputs/$fecha_inputs/applications/2022/Students/main_period/applications_mineduc/datos_jpal_2021-09-13_enviar.csv", clear delimiter(";") charset(utf8)
bys id_postulante: keep if _n==1 

sort id_postulacion
gen admission_system_id = 1
expand 2
gen round = .
bys id_postulante: replace round = 11 if _n == 1
bys id_postulante: replace round = 12 if _n == 2

gen year = $year

tempfile sae2022_ronda1
save `sae2022_ronda1'


* SAE 2022: ronda 2
import delimited "$pathData/inputs/$fecha_inputs/applications/2022/Students/complementary_period/applications_mineduc/datos_jpal_2021-12-14_enviar.csv", clear delimiter(";") charset(utf8)
bys id_postulante: keep if _n==1 

sort id_postulacion
gen admission_system_id = 1
gen round = 21 
gen year = $year

* append
append using `sae2022_ronda1'
sort id_postulacion

* applicant ids
preserve
bys id_postulante: keep if _n==1
gen id = _n
keep id_postulante id

tempfile applicant_ids
save `applicant_ids', replace 
restore

merge m:1 id_postulante using `applicant_ids'
drop _m
tostring round admission_system_id id, replace 

gen year_aux=year-2000
tostring admission_system_id round year_aux, replace 

* --- crear id único para el registro histórico
/*
 applicant_id   = country_code + ultimos dos digitos del año + admission_system_id (dos digitos, si es 1 se le agrega un 0) + 00 + id (AA)
 application_id = country_code + ultimos dos digitos del año + admission_system_id (dos digitos, si es 1 se le agrega un 0) + round (dos digitos) + id (AA)
*/
 

gen historic_applicant_id   = "56" + year_aux + "0" + admission_system_id + "00" + id
gen historic_application_id = "56" + year_aux + "0" + admission_system_id + round + id

sort id

*keep id_postulacion id_postulante historic_applicant_id historic_application_id
destring historic_applicant_id historic_application_id , replace
format historic_applicant_id historic_application_id %20.0f

destring round admission_system_id, replace  
drop id

keep id_postulacion id_postulante historic_application_id historic_applicant_id admission_system_id round

tempfile id_crosswalk
save `id_crosswalk'

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.csv", replace
save "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta", replace
}
*/

* --------------------------------------------------------------------------------
* Generar bases con ids nuevos
* --------------------------------------------------------------------------------

{
* -- ronda 11
import delimited "$pathData/inputs/$fecha_inputs/applications/2022/Students/main_period/applications_mineduc/datos_jpal_2021-09-13_enviar.csv", clear delimiter(";") charset(utf8)
gen round = 11
merge m:1 id_postulante round using "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta"
keep if _merge==3 
drop _merge

tempfile sae2022_ronda11_ids
save `sae2022_ronda11_ids'

* -- ronda 1 lista de espera 
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/detalle_asignacion_lista_espera.csv", clear
gen round = 12
merge m:1 id_postulante round using "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta"
keep if _merge==3 
drop _merge

tempfile sae2022_ronda12_ids
save `sae2022_ronda12_ids'


import delimited "$pathData/inputs/$fecha_inputs/applications/2022/Students/complementary_period/applications_mineduc/datos_jpal_2021-12-14_enviar.csv", clear delimiter(";") charset(utf8)
gen round = 21
merge m:1 id_postulante round using "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta"
keep if _merge==3 
drop _merge 

tempfile sae2022_ronda21_ids
save `sae2022_ronda21_ids'
}

* --------------------------------------------------------------------------------
* TABLA VACANCIES
* --------------------------------------------------------------------------------
*reemplazar esto por bases sae 
*agregar 2020 (2021)
*todo mineduc reemplazar 
{
import delimited "$pathData/inputs/$fecha_inputs/applications/2022/Schools/oferta_jpal_2021-08-06.csv", clear

* --- calculo de vacantes
replace preinscritos = 0 if preinscritos == .
replace repitencia_n_anterior = 0 if repitencia_n_anterior == .
replace total_cupos = 0 if total_cupos == .
replace repitencia_n = 0 if repitencia_n == .
gen aux1 = preinscritos - repitencia_n_anterior
replace aux1 = 0 if aux1 <0
gen aux2 = total_cupos - repitencia_n - aux1
replace aux2 = 0 if aux2 <0
rename aux2 vacancies
drop aux1

* --- renombrar variables
rename (rbd)(institution_code)

* --- crear variables
gen double campus_code=institution_code*100000+cod_sede

gen quota_id = .
gen special_admission_id = .
gen round = 11
 
keep institution_code campus_code  cod_nivel cod_curso quota_id special_admission_id vacancies round

format cod_curso campus_code %30.0g
tempfile round1
save `round1'

import delimited "$pathData/inputs/$fecha_inputs/applications/2022/Schools/oferta_jpal_complementario_2021-11-22.csv", clear

* --- calculo de vacantes
replace preinscritos = 0 if preinscritos == .
replace repitencia_n_anterior = 0 if repitencia_n_anterior == .
replace total_cupos = 0 if total_cupos == .
replace repitencia_n = 0 if repitencia_n == .
gen aux1 = preinscritos - repitencia_n_anterior
replace aux1 = 0 if aux1 <0
gen aux2 = total_cupos - repitencia_n - aux1
replace aux2 = 0 if aux2 <0
rename aux2 vacancies
drop aux1

* --- renombrar variables
rename (rbd)(institution_code)

* --- crear variables
gen double campus_code=institution_code*100000+cod_sede
 
gen quota_id = .
gen special_admission_id = .
gen round = 21
 
keep institution_code campus_code round cod_nivel cod_curso quota_id special_admission_id vacancies

format cod_curso campus_code %30.0g

append using `round1'

merge m:1 institution_code cod_curso using `programid'
keep if _merge==3
drop _merge

* --- year
gen year =$year
 
keep institution_code campus_code year round quota_id special_admission_id gender_label_id shift_label_id program_id gradetrack_id vacancies 
order institution_code campus_code year round quota_id special_admission_id gender_label_id shift_label_id program_id gradetrack_id vacancies 

sort institution_code campus_code gradetrack_id

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_vacancies_historic.csv", replace
}

* --------------------------------------------------------------------------------
* TABLA APPLICANTS
* --------------------------------------------------------------------------------
{
* SAE 2022: ronda 11
use `sae2022_ronda11_ids', replace 
bys historic_applicant_id: keep if _n==1 

sort historic_applicant_id

*gen round = 11
*gen year = $year

tempfile sae2022_ronda11
save `sae2022_ronda11'


* SAE 2022: ronda 21
use `sae2022_ronda21_ids', replace 

bys historic_applicant_id: keep if _n==1 

*gen round = 21 
*gen year = $year

append using `sae2022_ronda11'
bys historic_applicant_id: keep if _n==1 

gen location_id = .
gen user_id = .
gen applicant_registered = ""
gen personalized_name = ""
gen birth_date = ""
gen nationality_id = .
gen identification_type_id = .
gen identification_number = ""
gen identification_link = ""
gen first_name = nombre_post
gen other_name = ""
gen first_lastname = primer_apellido_post
gen other_lastname = ""

gen gender_id = 1 if genero =="M"
replace gender_id = 2 if genero =="F"

gen birth_location_id = .
gen relationship_id = .
gen relationship_other = ""
gen mother_nationality_id = .
gen mother_identification_type_id = .
gen mother_identification_number = ""
gen mother_first_name = ""
gen mother_other_name = ""
gen mother_first_lastname = ""
gen mother_other_lastname = ""
gen father_nationality_id = .
gen father_identification_type_id = .
gen father_identification_number = ""
gen father_first_name = ""
gen father_other_name = ""
gen father_first_lastname = "" 
gen father_other_lastname = ""
gen uuid = ""
gen created = ""
gen modified = fechamodificacion
gen registred = fecharegistro
gen mother_firstname = ""
gen father_firstname = ""
gen identification_link_1 = ""
gen identification_link_2 = ""

gen user_identification_type_id = .
gen user_identification_number = ""
gen user_identification_link_1 = ""
gen user_identification_link_2 = ""

gen current_applicant_id = .

gen id = _n

keep id historic_applicant_id location_id user_id applicant_registered personalized_name birth_date nationality_id identification_type_id identification_number identification_link ///
first_name other_name first_lastname other_lastname gender_id birth_location_id relationship_id relationship_other mother_nationality_id mother_identification_type_id ///
mother_identification_number mother_first_name mother_other_name mother_first_lastname mother_other_lastname father_nationality_id father_identification_type_id ///
father_identification_number father_first_name father_other_name father_first_lastname father_other_lastname uuid created modified registred mother_firstname ///
father_firstname identification_link_1 identification_link_2 user_identification_type_id user_identification_number user_identification_link_1 user_identification_link_2 current_applicant_id

order id historic_applicant_id location_id user_id applicant_registered personalized_name birth_date nationality_id identification_type_id identification_number identification_link ///
first_name other_name first_lastname other_lastname gender_id birth_location_id relationship_id relationship_other mother_nationality_id mother_identification_type_id ///
mother_identification_number mother_first_name mother_other_name mother_first_lastname mother_other_lastname father_nationality_id father_identification_type_id ///
father_identification_number father_first_name father_other_name father_first_lastname father_other_lastname uuid created modified registred mother_firstname ///
father_firstname identification_link_1 identification_link_2 user_identification_type_id user_identification_number user_identification_link_1 user_identification_link_2 current_applicant_id

replace first_name = subinstr(first_name, "'", "", .)
replace first_name = subinstr(first_name, "-", "", .)

duplicates report historic_applicant_id
export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/registration_applicant_historic.csv", replace
}

* --------------------------------------------------------------------------------
* TABLA APPLICATION
* --------------------------------------------------------------------------------
{
* SAE 2022: ronda 11
use `sae2022_ronda11_ids', clear 
bys historic_applicant_id: keep if _n==1 

gen application_status = ""
gen risk_from_loading = .
gen risk_from_api = .

keep historic_application_id historic_applicant_id application_status risk_from_loading risk_from_api admission_system_id round
order historic_application_id historic_applicant_id application_status risk_from_loading risk_from_api admission_system_id round

tempfile sae2022_ronda11_application
save `sae2022_ronda11_application'

* SAE 2022: ronda 12
use `sae2022_ronda12_ids', clear 
bys historic_applicant_id: keep if _n==1 

gen application_status = ""
gen risk_from_loading = .
gen risk_from_api = .


keep historic_application_id historic_applicant_id application_status risk_from_loading risk_from_api admission_system_id round
order historic_application_id historic_applicant_id application_status risk_from_loading risk_from_api admission_system_id round

tempfile sae2022_ronda12_application
save `sae2022_ronda12_application'

* SAE 2022: ronda 21
use `sae2022_ronda21_ids', clear 
bys historic_applicant_id: keep if _n==1 

gen application_status = ""
gen risk_from_loading = .
gen risk_from_api = .


keep historic_application_id historic_applicant_id application_status risk_from_loading risk_from_api admission_system_id round
order historic_application_id historic_applicant_id application_status risk_from_loading risk_from_api admission_system_id round

append using `sae2022_ronda11_application'
append using `sae2022_ronda12_application'

duplicates report historic_application_id //no deberían haber duplicados
duplicates report historic_applicant_id round //no deberían haber duplicados

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_application_historic.csv", replace
}
 
* --------------------------------------------------------------------------------
* TABLA APPLICATION RANKING
* --------------------------------------------------------------------------------
{
* --- RONDA 11
use `sae2022_ronda11_ids', clear

rename  (rbd orden)(institution_code historic_application_rank)
merge m:1 institution_code cod_curso using `programid'
keep if _merge==3
drop _merge

tempfile sae2022_ronda11_ranking
save `sae2022_ronda11_ranking', replace 

* --- RONDA 12
use `sae2022_ronda12_ids', clear

rename  (rbd orden)(institution_code historic_application_rank)
merge m:1 institution_code cod_curso using `programid'
keep if _merge==3
drop _merge

tempfile sae2022_ronda12_ranking
save `sae2022_ronda12_ranking', replace 

* --- RONDA 21
use `sae2022_ronda21_ids', clear 

rename  (rbd orden)(institution_code historic_application_rank)

merge m:1 institution_code cod_curso using `programid'
keep if _merge==3
drop _merge

append using `sae2022_ronda11_ranking'
append using `sae2022_ronda12_ranking'

sort historic_application_id
gen id = _n

keep id historic_application_id program_id historic_application_rank
order id historic_application_id program_id historic_application_rank

duplicates report historic_application_id historic_application_rank //no deberían haber duplicados

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_application_ranking_historic.csv", replace
}

* --------------------------------------------------------------------------------
* TABLA INSTITUTIONS ADMISSION
* --------------------------------------------------------------------------------
{
* --- RONDA 11
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/detalle_asignacion.csv", clear
rename (rbd)(institution_code)
format cod_curso %20.0f

keep if admitido == 1
gen round = 11

tempfile admission_11
save `admission_11', replace

* --- RONDA 12
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/detalle_asignacion_lista_espera.csv", clear
rename (rbd)(institution_code)
format cod_curso %20.0f

keep if admitido == 1
gen round = 12

replace total_lista_espera = "." if total_lista_espera == "-"
destring total_lista_espera, replace 

tempfile admission_12
save `admission_12', replace

* --- RONDA 21
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/detalle_asignacion_complementario.csv", clear
rename (rbd)(institution_code)
format cod_curso %20.0f

keep if admitido == 1
gen round = 21

replace total_lista_espera = "." if total_lista_espera == "-"
destring total_lista_espera, replace 
 
* --- append 
append using `admission_11'
append using `admission_12'
sort round id_postulante

merge m:1 institution_code cod_curso using `programid'
keep if _merge==3
drop _merge

merge 1:1 id_postulante round using "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta"
keep if _merge == 3
drop _merge

gen admission_status_id = .

sort historic_application_id
* --admission id = application id (por ahora)
gen double admission_id = historic_application_id
format admission_id %20.0f

duplicates report historic_applicant_id round //no deberían haber duplicados
duplicates report historic_application_id //no deberían haber duplicados

keep admission_id historic_application_id program_id admission_status_id
order admission_id historic_application_id program_id admission_status_id

*Arreglos nombres y otros
rename admission_id id
rename historic_application_id application_id
gen year = $year


export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_admission_historic.csv", replace
}

* --------------------------------------------------------------------------------
* TABLA ADMISSION CHOICE
* --------------------------------------------------------------------------------
{
* --- RONDA 11
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/principal_respuesta.csv", clear varn(1)

gen round = 11
merge 1:1 id_postulante round using "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta"
keep if _merge ==3  
drop _merge 

gen double admission_id = historic_application_id
format admission_id %20.0f

gen choice_id = 1 if respuesta == "ACEPTADO"
replace choice_id = 2 if respuesta == "ACEPTADO_DEFAULT"
replace choice_id = 3 if respuesta == "LISTA_ESPERA"
replace choice_id = 4 if respuesta == "LISTA_ESPERA_AUTOMATICA"
replace choice_id = 5 if respuesta == "RECHAZADO"

tempfile choice_11
save `choice_11', replace 

* --- RONDA 12
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/listas_espera_respuesta.csv", clear varn(1)

gen round = 12
merge 1:1 id_postulante round using "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta"
keep if _merge ==3  
drop _merge 

gen double admission_id = historic_application_id
format admission_id %20.0f

gen choice_id = 1 if respuesta == "ACEPTADO"
replace choice_id = 2 if respuesta == "ACEPTADO_DEFAULT"
replace choice_id = 5 if respuesta == "RECHAZADO"
replace choice_id = 6 if respuesta == "SIN_ASIGNACION"

* --- RONDA 21: NO TIENE RESPUESTA
* --- --- 

append using `choice_11'
gen id = _n

keep id admission_id choice_id 
order id admission_id choice_id
format admission_id %20.0f

duplicates report admission_id //no deberían haber duplicados

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_admission_choice_historic.csv", replace
}
  
* --------------------------------------------------------------------------------
* TABLA INSTITUTIONS ASSIGNMENT
* -------------------------------------------------------------------------------
{
* --- RONDA 11 --- * 
* ASIGNACION
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/detalle_asignacion.csv", clear
rename (rbd)(institution_code)
format cod_curso %20.0f

tempfile asignacion_11
save `asignacion_11', replace

* RESPUESTA
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/principal_respuesta.csv", clear varn(1)
merge 1:m id_postulante using `asignacion_11' //deberían pegar todos

keep id_postulante respuesta institution_code cod_curso orden_preferencia_final glosa_estado admitido
order id_postulante glosa_estado respuesta institution_code cod_curso orden_preferencia_final
sort id_postulante orden_preferencia_final

tab glosa_estado if respuesta == "ACEPTADO"
tab glosa_estado if respuesta == "ACEPTADO_DEFAULT"
tab glosa_estado if respuesta == "LISTA_ESPERA"
tab glosa_estado if respuesta == "LISTA_ESPERA_AUTOMATICA"

gen flag = 1 if glosa_estado == "ADMITIDO_POR_PREFERENCIA" & respuesta == "ACEPTADO"
replace flag = 1 if glosa_estado == "ADMITIDO_POR_MATRICULA_ASEGURADA" & respuesta == "ACEPTADO"
replace flag = 1 if glosa_estado == "ADMITIDO_POR_PREFERENCIA" & respuesta == "ACEPTADO_DEFAULT"
replace flag = 1 if glosa_estado == "ADMITIDO_POR_MATRICULA_ASEGURADA" & respuesta == "ACEPTADO_DEFAULT"

keep if flag != .
gen round = 11

tempfile assignment_11
save `assignment_11', replace 

* --- RONDA 12 --- * 
* ASIGNACION
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/detalle_asignacion_lista_espera.csv", clear
rename (rbd)(institution_code)
format cod_curso %20.0f

tempfile asignacion_12
save `asignacion_12', replace

* RESPUESTA
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/listas_espera_respuesta.csv", clear varn(1)
merge 1:m id_postulante using `asignacion_12' //deberían pegar todos

keep id_postulante respuesta institution_code cod_curso orden_preferencia_final glosa_estado admitido
order id_postulante glosa_estado respuesta institution_code cod_curso orden_preferencia_final
sort id_postulante orden_preferencia_final

tab glosa_estado if respuesta == "ACEPTADO"
tab glosa_estado if respuesta == "ACEPTADO_DEFAULT"

gen flag = 1 if glosa_estado == "ADMITIDO_POR_MATRICULA_ASEGURADA" & respuesta == "ACEPTADO"
replace flag = 1 if glosa_estado == "ADMITIDO_POR_PREFERENCIA" & respuesta == "ACEPTADO"
replace flag = 1 if glosa_estado == "ADMITIDO_POR_PREFERENCIA" & respuesta == "ACEPTADO_DEFAULT"

keep if flag != .
gen round = 12

append using `assignment_11'
duplicates report id_postulante

tempfile assignment_ronda1
save `assignment_ronda1', replace 

* --- RONDA 21 --- *
import delimited "$pathData/inputs/$fecha_inputs/admissions/2022/detalle_asignacion_complementario.csv", clear
rename (rbd)(institution_code)
format cod_curso %20.0f

gen flag = 1 	 if glosa_estado == "ADMITIDO_POR_DISTANCIA"
replace flag = 1 if glosa_estado == "ADMITIDO_POR_MATRICULA_ASEGURADA"
replace flag = 1 if glosa_estado == "ADMITIDO_POR_PREFERENCIA"
keep if flag !=.
duplicates report id_postulante

gen round = 21
* --- append
append using `assignment_ronda1'
duplicates report id_postulante //no deberían haber duplicados 

* ---  merge program ids
merge m:1 institution_code cod_curso using `programid'
keep if _merge==3
drop _merge

* -- id postulante -- *
merge 1:1 id_postulante round using "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/id_crosswalk.dta"
keep if _merge ==3 
drop _merge 
 
gen quota_id =  4 //regular
gen special_assignment_id = .

rename historic_* *
sort application_id 
gen id = _n

keep id application_id program_id quota_id special_assignment_id
order id  application_id program_id quota_id special_assignment_id

duplicates report application_id //503,171

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_assignment_historic.csv", replace

}

* --------------------------------------------------------------------------------
* TABLA INSTITUTIONS ADMISSION CHOICE LABEL 
* --------------------------------------------------------------------------------

clear 
set obs 6
gen choice_id = _n
gen choice_label = "ACEPTADO" 
replace choice_label = "ACEPTADO_DEFAULT" 		  if _n == 2 
replace choice_label = "LISTA_ESPERA" 	          if _n == 3 
replace choice_label = "LISTA_ESPERA_AUTOMATICA"  if _n == 4 
replace choice_label = "RECHAZADO"  			  if _n == 5 
replace choice_label = "NO_APLICA"  	  	      if _n == 6 

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_admission_choice_label_historic.csv", replace


* --------------------------------------------------------------------------------
* TABLA INSTITUTIONS ADMISSION STATUS LABEL
* --------------------------------------------------------------------------------

clear 
gen admission_status_id = _n
gen admission_status_label = ""

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_admission_status_label_historic.csv", replace


* --------------------------------------------------------------------------------
* TABLA IDENTIFICATION TYPE LABEL 
* --------------------------------------------------------------------------------

clear 
gen identification_type_id = .
gen identification_type_label = ""

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_identification_type_label_historic.csv", replace


* --------------------------------------------------------------------------------
* TABLA APPLICATION HISTORY 
* --------------------------------------------------------------------------------

clear 
gen historic_application_history_id = .
gen historic_application_id = .
gen application_status = ""
gen risk_from_api = .
gen timestamp = .

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_application_history_historic.csv", replace


* --------------------------------------------------------------------------------
* TABLA APPLICATIONS RANKING HISTORY 
* --------------------------------------------------------------------------------

clear 
set obs 1
gen historic_application_history_id = .
gen program_id = .
gen historic_application_rank = .

gen id = _n

export delimited "$pathData/outputs/$mode_outputs/$fecha_outputs_upload/historic/institutions_application_ranking_history_historic.csv", replace


* --------------------------------------------------------------------------------
* TABLA QUOTA LABEL 
* --------------------------------------------------------------------------------

clear
set obs 4
gen quota_id = _n
gen quota_label = "PIE" if _n == 1
replace quota_label = "Alta Exigencia" if _n == 2
replace quota_label = "Prioritario" if _n == 3
replace quota_label = "Regular" if _n == 4

gen quota_label_es = quota_label
gen quota_label_en = ""

export delimited "$pathData/outputs/upload/$fecha_outputs_upload/historic/institutions_quota_label_historic.csv", replace

* --------------------------------------------------------------------------------
* TABLA SPECIAL ADMISSION LABEL
* --------------------------------------------------------------------------------

clear
set obs 1
gen special_admission_id = _n
gen special_admission_label = ""

gen special_admission_label_es = special_admission_label
gen special_admission_label_en = ""

export delimited "$pathData/outputs/upload/$fecha_outputs_upload/historic/institutions_special_admission_label_historic.csv", replace
