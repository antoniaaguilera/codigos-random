global pathExplorador ="/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/latest_from_back"

* --- audiovisual --- *
import delimited "$pathExplorador/cb_explorer_chile_institutions_audiovisual.csv", clear 

gen sobrevuelo  		 = (audiovisual_label_id == 1)
gen tour_virtual 		 = (audiovisual_label_id == 2)
gen testimonio_directivo = (audiovisual_label_id == 3 | audiovisual_label_id == 9  | audiovisual_label_id == 10 | audiovisual_label_id == 11 | audiovisual_label_id == 12 | audiovisual_label_id == 13)
gen testimonio_docente   = (audiovisual_label_id == 4 | audiovisual_label_id == 14 | audiovisual_label_id == 15 | audiovisual_label_id == 16 | audiovisual_label_id == 17 | audiovisual_label_id == 18)
gen testimonio_apoderado = (audiovisual_label_id == 5 | audiovisual_label_id == 19 | audiovisual_label_id == 20 | audiovisual_label_id == 21 | audiovisual_label_id == 22 | audiovisual_label_id == 23)
gen testimonio_exalumno  = (audiovisual_label_id == 6 | audiovisual_label_id == 24 | audiovisual_label_id == 25 | audiovisual_label_id == 26 | audiovisual_label_id == 27 | audiovisual_label_id == 28)
gen video_institucional  = (audiovisual_label_id == 7 | audiovisual_label_id == 29 | audiovisual_label_id == 30 | audiovisual_label_id == 31 | audiovisual_label_id == 32 | audiovisual_label_id == 33)
gen capsula_proyectoed   = (audiovisual_label_id == 8 | audiovisual_label_id == 34 | audiovisual_label_id == 35 | audiovisual_label_id == 36 | audiovisual_label_id == 37 | audiovisual_label_id == 38)

collapse (firstnm) sobrevuelo tour_virtual testimonio_directivo testimonio_docente testimonio_apoderado testimonio_exalumno video_institucional capsula_proyectoed, by(campus_code)

tempfile audiovisual
save `audiovisual', replace 

* --- campus --- *
import delimited "$pathExplorador/cb_explorer_chile_institutions_campus.csv", clear 

gen preescolar = 1 if grade_max=="Atención Temprana"| grade_max=="Kinder"| grade_max=="Kinder (Nivel de Transición 2)"| grade_max=="Nivel Medio Heterogéneo"| grade_max=="Nivel Medio Mayor"| grade_max=="Nivel Medio Menor"| grade_max=="Nivel Transición Heterogéneo"| grade_max=="Nivel de Transición 1"| grade_max=="Nivel de Transición 2"| grade_max=="Parvularia Heterogéneo"| grade_max=="PreKinder (Nivel de Transición 1)"| grade_max=="Sala Cuna Heterogéneo"| grade_max=="Sala Cuna Mayor"| grade_max=="Sala Cuna Menor"
replace preescolar = 0 if preescolar==.

keep institution_code campus_code religion_id sector_id campus_name preescolar

merge m:1 campus_code using `audiovisual'
drop _merge 
rename sector_id dependencia 
rename campus_name nombre 

foreach var in video_institucional capsula_proyectoed {
	replace `var' = 0 if `var' == .
}
tempfile campus
save `campus'

* --- sector label --- *
import delimited "$pathExplorador/cb_explorer_chile_institutions_sector_label.csv", clear 
rename id dependencia
merge 1:m dependencia using `campus'
drop _merge
rename sector_name dependencia_label

tempfile sector 
save `sector'

* --- religion label --- *
import delimited "$pathExplorador/cb_explorer_chile_institutions_religion_label.csv", clear 
rename id religion_id
merge 1:m religion_id using `sector'
rename religion_name religion_label
rename religion_id religion
bys campus_code: keep if _n==1
keep campus_code institution_code nombre dependencia dependencia_label religion religion_label sobrevuelo testimonio_* tour_virtual preescolar video_institucional capsula_proyectoed
order campus_code institution_code nombre dependencia dependencia_label religion religion_label sobrevuelo testimonio_* tour_virtual video_institucional capsula_proyectoed

rename institution_code rbd

tempfile religion
save `religion'

* --- contact --- *
*import delimited "$pathExplorador/cb_explorer_chile_institutions_contact.csv", clear 
import delimited "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/Explorador_Chile/E_Escolar/latest_to_back/institutions_contact.csv", clear

gen contacto_oficina   = (contact_label_id == 1)
gen contacto_cepadres  = (contact_label_id == 2)
gen contacto_facebook  = (contact_label_id == 3)
gen contacto_twitter   = (contact_label_id == 4)
gen contacto_instagram = (contact_label_id == 5)
gen contacto_director  = (contact_label_id == 6)

gen mail_oficina  = email if contact_label_id == 1 
gen mail_cepadres = email if contact_label_id == 2
gen mail_director = email if contact_label_id == 6

gen sitio_web = webpage 

gen nombre_cepadre  = name if contact_label_id == 2

collapse (firstnm) contacto_* mail_* webpage nombre*, by(campus_code)

merge 1:1 campus_code using `religion'
drop _merge 
drop if campus_code==.

rename nombre nombre_rbd
order rbd campus_code nombre_rbd dependencia* religion* contacto* nombre* mail* 

tempfile contact_aux
save `contact_aux', replace 

import delimited "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/data_random/directores/contact_directores.csv", clear
gen nombre_director = name+" "+other_name+ " "+first_lastname+" "+other_lastname
rename institution_code rbd
keep rbd nombre_director
merge 1:m rbd using `contact_aux'
drop _merge
tempfile contact
save `contact', replace 

* --- images --- *
import delimited "$pathExplorador/cb_explorer_chile_institutions_images.csv", clear 
tostring campus_code, generate(rbd) format(%20.0g)
replace rbd = subinstr(rbd, "00001", "", .)
replace rbd = subinstr(rbd, "00002", "", .)
replace rbd = subinstr(rbd, "00003", "", .)
replace rbd = subinstr(rbd, "00004", "", .)
replace rbd = subinstr(rbd, "00005", "", .)

bys rbd: egen n_fotos = count(order)
keep rbd n_fotos
bys rbd: keep if _n==1
destring rbd, replace 
merge 1:m rbd using `contact'

drop _merge 
order rbd campus_code nombre_rbd 

export excel "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/data_random/para_andrea/info_explorador.xlsx", replace firstrow(variables)
