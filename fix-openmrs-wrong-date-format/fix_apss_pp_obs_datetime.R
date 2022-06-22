library(lubridate)
# Ficha APSS e PP (Actual e Proxima)
# Fix 202 dates  in Ficha APSS e PP
# Criteria : Check  date_created first  ( value_datetime  > obs_datetime)
# EncounterDate: Actual
# 6310 -DATA DO PROXIMO ACONSELHAMENTO

query_apss_pp_actual_prox <- "Select  person_id, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id
Where YEAR(obs_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and concept_id = 6310 and o.voided =0 ; "

df_apss_pp <- getOpenmrsData(con_openmrs,query_apss_pp_actual_prox)

if(nrow(df_apss_pp)>0){
  for (i in 1:dim(df_apss_pp)[1]) {
    
    
    encounter_id <- df_apss_pp$encounter_id[i]
    ano_value <- df_apss_pp$ano_value[i]
    encounter_created <- df_apss_pp$encounter_created[i]
    obs_datetime <- df_apss_pp$obs_datetime[i]
    value_datetime <- df_apss_pp$value_datetime[i]
    
    ## Muda obs_datetime e compara com value_datime
    if(ano_value==encounter_created){
      
      
      tmp_obs_datetime <- as.Date( paste0(ano_value,substr(obs_datetime, 5,nchar(obs_datetime)) ) )
      tmp_value_datetime <-  as.Date(value_datetime)
      
      if( tmp_obs_datetime < tmp_value_datetime ){
        update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
        update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
        write(update_query_encounter,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
        write(update_query_obs,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
      } else {
        ano_value = ano_value -1
        
        tmp_obs_datetime <- as.Date( paste0(ano_value,substr(obs_datetime, 5,nchar(obs_datetime)) ) )
        if( as.integer( tmp_value_datetime  -tmp_obs_datetime) < 190 ){
          update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
          update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
          write(update_query_encounter,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
          write(update_query_obs,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
          
        } else {     
          print(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "))
          write(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "),file="error_obs_encounter_apss_pp.txt",append=TRUE)
        }
        
        
      }
      
      
    } else {
      
      if(ano_value < 1000){
        tmp_obs_datetime <- as.Date( paste0(encounter_created,substr(obs_datetime, 5,nchar(obs_datetime)) ) )
        tmp_value_datetime <-  as.Date(value_datetime)
        update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
        update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
        write(update_query_encounter,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
        write(update_query_obs,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
        
      } else {
        
        tmp_obs_datetime <- as.Date( paste0(encounter_created,substr(obs_datetime, 5,nchar(obs_datetime)) ) )
        tmp_value_datetime <-  as.Date(value_datetime)
        
        
        if( tmp_obs_datetime < tmp_value_datetime ){
          update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
          update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
          write(update_query_encounter,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
          write(update_query_obs,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
        } else {
          tmp_obs_datetime <- as.Date( paste0(ano_value,substr(obs_datetime, 5,nchar(obs_datetime)) ) )
          if( tmp_obs_datetime < tmp_value_datetime ){
            update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
            update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
            write(update_query_encounter,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
            write(update_query_obs,file="fix_obs_encounter_apss_pp_obs_dates_querys.txt",append=TRUE)
          }
        }
        
      }
      
      
      
    }
  }
  
  
  
}

