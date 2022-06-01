
/*
Será posible crear por favor una base única para abordar con Tether con los campos adjuntos (si no tienen la data dejar campo vacío) cruzada con la base de:
- Eli de establecimientos regalones (importante si son poner en el campo Regalones SI)
- Javier de base de sostenedores
- Establecimientos con contenido audiovisual en MIME. (importante si son poner en el campo SI)
- Base Marcy actualizada RRSS
- todos los jardines infantiles que no sean (JUNJI O MIME) con o sin RBD, pero lo que tengamos en la base.
*/

global pathData "/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/random_data/bases andrea_marcy/hubspot"

* --- audiovisual update --- *
import excel "$pathData/inputs_base_hubspot/audiovisual_cl.xlsx", clear first
rename RBD rbd
rename (SV TV Testimonio EsRegalon)(sobre_vuelo tour_virtual testimonio nivel_regalon)

gen perfil_digital_completo =  (sobre_vuelo==1&tour_virtual==1&testimonio==1)
gen regalones = (nivel_regalon>0)

foreach var in sobre_vuelo tour_virtual testimonio perfil_digital_completo regalones {
	tostring `var', replace 
	replace `var' = "SI" if `var' == "1"
	replace `var' = "NO" if `var' == "0"
}

tempfile regalones_audiovisual 
save `regalones_audiovisual', replace 

* --- sostenedores --- *
import delimited "$pathData/inputs_base_hubspot/base_sostenedores.csv", clear
rename (rut mrun p_juridica nombre_sost contacto)(sostenedor_rut sostenedor_mrun sostenedor_pjuridica sostenedor_nombre sostenedor_mail)
rename (institution_name)(estab_nombre)

merge 1:1 rbd using `regalones_audiovisual', nogen

tempfile sostenedores
save `sostenedores', replace 

* --- lista establecimientos --- *
import delimited "$pathData/inputs_base_hubspot/lista_establecimientos.csv", clear 
merge 1:1 rbd using `sostenedores', nogen 

replace sostenedor_nombre = sostenedor_1 if sostenedor_nombre ==""
replace sostenedor_nombre = sostenedor_2 if sostenedor_nombre ==""

rename sostenedor_1 sostenedor_1_gasto
rename sostenedor_2 sostenedor_2_gasto

replace testimonio = "NO" if  testimonio == ""
replace tour_virtual = "NO" if tour_virtual == ""
replace sobre_vuelo = "NO" if sobre_vuelo == ""

tostring rbd, replace 

tempfile intermedia
save `intermedia', replace 

* ==============================================================================
* LLAMAR A GOOGLE SHEETS (base marcy)
* ==============================================================================

local anything "$pathData/inputs_base_hubspot/base_hunters.csv"


capture program drop gsheet
program define gsheet
    syntax anything , key(string) id(string)
    
    local url "https://docs.google.com/spreadsheets/d/`key'/export?gid=`id'&format=csv"
    
    copy "`url'" `anything', replace
    
    noi disp `"saved in `anything'"'
    
    import delim using `anything', clear
end
gsheet "$pathData/inputs_base_hubspot/base_hunters.csv" , key("11I9sYsQ0Xhhj7sC4eKbK7ytvNTfrEeTcuMsunDIGAe0") id("0") //tbh, ni idea como funciona este código, pero funciona jeje

drop if missing(real(institution_code))

keep if status_datos == "Validado"

* --- directores 
replace nombre_director = new_nombre_director if confirm_nombredirector == "0"
replace email_director  = new_mail_director if confirm_maildirector == "0"

* --- rrss --- *
rename text_instagram instagram 
rename text_twitter twitter
rename text_fcb facebook 
 
*poner @ a todos 
replace instagram = subinstr(instagram, "@", "", 1)
replace instagram = "@"+instagram
 
keep institution_code nombre_director email_director instagram twitter facebook mail_admision phone_admision numero_efectivo num_add num_add2 num_add3

gen str rbd = institution_code
drop institution_code
merge 1:1 rbd using `intermedia', nogen

*tempfile intermedia2
*save `intermedia2', replace 
 
local date = "$S_DATE"

export excel "$pathData/base_hubspot_`date'.xlsx", replace first(variables)

stop
* --- jardines --- * 
import delimited "$pathData/inputs_base_hubspot/supply_preview.csv", clear
keep institution_code sector
rename institution_code rbd 
rename sector dependencia 

merge 1:1 rbd using `intermedia2'




