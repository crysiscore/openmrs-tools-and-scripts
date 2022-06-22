library(lubridate)
# Ficha APSS e PP (Actual e Proxima)
# Fix 202 dates  in Ficha APSS e PP
# Criteria : Check  date_created first  ( value_datetime  > obs_datetime)
# EncounterDate: Actual
# 6310 -DATA DO PROXIMO ACONSELHAMENTO

query_apss_pp_actual_prox_valuetd <- "Select  person_id, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_obs, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id
Where YEAR(value_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and concept_id = 6310 and o.voided =0 ; "

df_apss_pp_value_dt_value_dt_value_dt <- getOpenmrsData(con_openmrs,query_apss_pp_actual_prox_valuetd)

if(nrow(df_apss_pp_value_dt_value_dt_value_dt)>0){
        for (i in 1:dim(df_apss_pp_value_dt_value_dt_value_dt)[1]) {
                encounter_id <- df_apss_pp_value_dt_value_dt_value_dt$encounter_id[i]
                ano_obs <- df_apss_pp_value_dt_value_dt_value_dt$ano_obs[i]
                encounter_created <- df_apss_pp_value_dt_value_dt_value_dt$encounter_created[i]
                obs_datetime <- df_apss_pp_value_dt_value_dt_value_dt$obs_datetime[i]
                value_datetime <- df_apss_pp_value_dt_value_dt_value_dt$value_datetime[i]
                
                ## Muda obs_datetime e compara com value_datime
                if(ano_obs==encounter_created){
                        
                        tmp_value_datetime <- as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
                        tmp_obs_datetime <-  as.Date(obs_datetime)
                        
                        if( tmp_value_datetime >  tmp_obs_datetime ){
                                update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
                                write(update_query_obs,file="fix_obs_valuedt_apss_pp_querys.txt",append=TRUE)
                        } 
                        else {
                                ano_obs = ano_obs + 1
                                
                                tmp_value_datetime <- as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
                                if( as.integer( tmp_value_datetime  - tmp_obs_datetime) < 190 ){
                                        update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
                                        write(update_query_obs,file="fix_obs_valuedt_apss_pp_querys.txt",append=TRUE)
                                        
                                } else {     
                                        print(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "))
                                        write(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "),file="error_obs_encounter_apss_pp.txt",append=TRUE)
                                }
                                
                                
                        }
                        
                        
                } 
                else {
                        
                        tmp_value_datetime <- as.Date( paste0(encounter_created,substr(value_datetime, 5,nchar(value_datetime)) ) )
                        tmp_obs_datetime <-  as.Date(obs_datetime)
                        
                        if( tmp_value_datetime >  tmp_obs_datetime ){
                                
                                update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime= DATE_FORMAT(o.value_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
                                write(update_query_obs,file="fix_obs_valuedt_apss_pp_querys.txt",append=TRUE)
                        } else {
                                
                                tmp_value_datetime <- as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
                                tmp_obs_datetime <-  as.Date(obs_datetime)
                                if( tmp_value_datetime >  tmp_obs_datetime ){
                                        
                                        update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime= DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
                                        write(update_query_obs,file="fix_obs_valuedt_apss_pp_querys.txt",append=TRUE)
                                } else {
                                        
                                        print(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "))
                                        write(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "),file="error_obs_encounter_apss_pp.txt",append=TRUE)
                                        
                                }
                                
                                
                        }
                        
                }
        }
        
} 




