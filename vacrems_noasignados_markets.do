global path =  "C:\Users\ij1376\ConsiliumBots Dropbox\Isabel Jacas\data\checks_sae_2021\"

import delimited "$path/SAE_2021/B1_Postulantes_etapa_regular_2021_Admisión_2022_PUBL.csv", clear charset(utf8)
tempfile post
save `post'
import delimited "$path/SAE_2021/B2_Postulantes_etapa_complementaria_2021_Admisión_2022_PUBL.csv", clear charset(utf8)
append using `post'
duplicates drop mrun, force
keep mrun lat_con_error lon_con_error
replace lat = subinstr(lat,",",".",.)
replace lon = subinstr(lon,",",".",.)
destring lat lon, replace
export delimited "$path/markets/students_geoloc.csv", replace


import delimited "$path/markets/Students2Markets.csv", clear charset(utf8)
drop if market == 0
keep mrun market
tempfile students
save `students'


import delimited "$path/markets/Schools2Markets.csv", clear
keep if institution_code != .
drop if market == 0
keep institution_code market
rename institution_code rbd
tempfile markets
save `markets'

import delimited "$path/SAE_2021/A1_Oferta_Establecimientos_etapa_regular_2021_Admisión_2022.csv", clear charset(utf8)
collapse (sum) vacantes, by (rbd cod_nivel cod_curso)
merge m:1 rbd using `markets'
keep if _merge == 3
drop _merge
tempfile vacantes
save `vacantes'



import delimited "$path/SAE_2021/D1_Resultados_etapa_regular_2021_Admisión_2022_PUBL.csv", clear charset(utf8)
replace rbd_admitido = rbd_admitido_post_resp if rbd_admitido_post_resp == ""
replace cod_curso_admitido = cod_curso_admitido_post_resp if cod_curso_admitido_post_resp == ""
keep mrun cod_nivel rbd_admitido cod_curso_admitido
gen keep = 0
tempfile admitidos1
save `admitidos1'







import delimited "$path/SAE_2021/D2_Resultados_etapa_complementaria_2021_Admisión_2022_PUBL.csv", clear charset(utf8)
keep mrun cod_nivel rbd_admitido cod_curso_admitido
gen keep = 1
append using `admitidos1'
sort mrun keep
duplicates tag mrun, gen(dup)
drop if dup>0 & keep ==0
drop dup
duplicates report mrun
gen asignado = rbd_admitido != " "
merge 1:1 mrun using `students'
drop if _merge == 1

preserve
gen total = 1
collapse (sum) total asignado, by(market)
save "$path/markets/asignacion_por_mercado.dta", replace
export delimited "$path/markets/asignacion_por_mercado.csv", replace
restore

drop market _merge asignado keep
destring rbd_admitido cod_curso_admitido, replace
gen asignado = 1
drop if rbd == .
collapse (sum) asignado, by(rbd cod_nivel cod_curso_admitido)
rename rbd_admitido rbd
rename cod_curso_admitido cod_curso
merge 1:1 rbd cod_nivel cod_curso using `vacantes'
keep if _merge >= 2
replace asignado = 0 if _merge == 2
drop _merge
replace asignado = vacantes if asignado >vacantes
gen vacantes_rem = vacantes - asignado

collapse (sum) asignado vacantes vacantes_rem, by(market)
save "$path/markets/vacantes_remanentes_por_mercado.dta", replace
export delimited "$path/markets/vacantes_remanentes_por_mercado.csv", replace




use  "$path/markets/vacantes_remanentes_por_mercado.dta", clear
sum vacantes_rem, detail

gen vacantes_rem_p = vacantes_rem/vacantes

sum vacantes_rem_p, detail

use  "$path/markets/asignacion_por_mercado.dta", clear
gen no_asignado = total - asignado
gen no_asignado_p = no_asignado/total

sum no_asignado, detail
sum no_asignado_p, detail
