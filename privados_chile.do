* colegios privados
import delimited "/Users/antoniaaguilera/Dropbox/Mac (2)/Desktop/Data DFM/Matricula-por-estudiante-2021/20210913_Matrícula_unica_2021_20210430_WEB.CSV", clear 
/*
tab rbd 
di `r(r)' //11287

tab rbd if cod_depe2 == 1
di `r(r)' //4403

tab rbd if cod_depe2 == 2
di `r(r)' //5548

tab rbd if cod_depe2 == 3
di `r(r)' //PARTICULAR PAGADO: 623

*total: 4403+5548+623 = 10574
*/
// keep private schools in urban areas
keep if cod_depe2 == 3 & rural_rbd == 0
tab rbd
di `r(r)' //PARTICULAR PAGADO URBANOS: 617

/*
Solo como intro, quería pedirles a los country specialist 
(solo si tienen tiempo de verlo antes, y está fácil de ver, si no no se preocupen):
Cuántos colegios privados hay en zonas urbanas? Si tienen más detalle por niveles 
(primaria, secundaria), y si ya tienen aun más detalle, la distribución en las distintas zonas urbanas
*/


*ver adultos, etc
collapse (count) n_students =mrun , by(rbd cod_ense2 nom_com_rbd cod_com_rbd cod_reg_rbd)

keep if cod_ense2 == 2 | cod_ense2 ==5 | cod_ense2 == 7
bys cod_com_rbd rbd: egen min_ense = min(cod_ense2)
bys cod_com_rbd rbd: egen max_ense = max(cod_ense2)

gen solo_basica = (min_ense == 2 & max_ense == 2)
gen solo_media  = (min_ense == 5 | min_ense == 7)
gen basica_y_media = ( min_ense == 2 & (max_ense == 5 | max_ense == 7))

collapse (count) n_privados = rbd (sum) solo_basica solo_media basica_y_media , by(nom_com_rbd cod_com_rbd cod_reg_rbd)

gsort -n_privados
