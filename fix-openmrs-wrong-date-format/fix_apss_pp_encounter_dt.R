
library(lubridate)
# Ficha APSS e PP (Actual )
# Fix  dates  in Ficha APSS e PP
# EncounterDate: Actual


query_apss_pp_actual <- "Select  person_id, identifier,substr(identifier,12,4) as year, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id left join patient_identifier pi on pi.patient_id = e.patient_id
Where YEAR( o.obs_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and encounter_type= 35  and o.voided =0 and pi.identifier_type=2 ; "


df_ficha_apss_pp_encounter_dt <- getOpenmrsData(con_openmrs,query_apss_pp_actual)

if(nrow(df_ficha_apss_pp_encounter_dt)> 0){
  
  vec_encounter <- unique(df_ficha_apss_pp_encounter_dt$encounter_id)
  
  for (i in 1:length(vec_encounter)) {
    
    temp <- df_ficha_apss_pp_encounter_dt[df_ficha_apss_pp_encounter_dt$encounter_id==vec_encounter[i],]
    encounter_id <- temp$encounter_id[1]
    
    ano_value <- temp$ano_obs[1]
    encounter_created <- temp$encounter_created[1]
    obs_datetime <- temp$obs_datetime[1]
    value_datetime <- temp$value_datetime[1]
    encounter_datetime <- temp$encounter_datetime[1]
    
    
    update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
    
    if(obs_datetime ==encounter_datetime) {
      
      update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created ,"-%m-%d 00:00:00'), o.value_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
      write(update_query_encounter,file="fix_obs_encounter_ficha_apss_pp_encounter_dt_querys.txt",append=TRUE)
      write(update_query_obs,file="fix_obs_encounter_ficha_apss_pp_encounter_dt_querys.txt",append=TRUE)
    } 
    else {
      
      write(update_query_encounter,file="fix_obs_encounter_ficha_apss_pp_encounter_dt_querys.txt",append=TRUE)
    }  
    
  }
  
  
  
}


