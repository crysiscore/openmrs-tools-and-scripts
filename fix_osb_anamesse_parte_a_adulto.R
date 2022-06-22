
# ADULTO: PROCESSO PARTE A - ANAMNESE (S.TARV: ADULTO INICIAL A) 
# 6123 - Data de Diagnóstico
#  Data abertura do Processo : encounterDate


query_anamnese_parte <- "Select  person_id, identifier,substr(identifier,12,4) as year, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id left join patient_identifier pi on pi.patient_id = e.patient_id
Where YEAR(obs_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and concept_id = 6123 and o.voided =0 and pi.identifier_type=2 ; "

df_anamnese_parte_a <- getOpenmrsData(con_openmrs,query_anamnese_parte)

if(nrow(df_anamnese_parte_a)>0){
  if(nrow(df_anamnese_parte_a)>0){
    
    for (i in 1:dim(df_anamnese_parte_a)[1]) {
      
      
      encounter_id <- df_anamnese_parte_a$encounter_id[i]
      ano_value <- df_anamnese_parte_a$year[i]
      encounter_created <- df_anamnese_parte_a$encounter_created[i]
      obs_datetime <- df_anamnese_parte_a$obs_datetime[i]
      value_datetime <- df_anamnese_parte_a$value_datetime[i]
      
      if(ano_value==encounter_created){
        
        update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
        update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created ,"-%m-%d 00:00:00'), o.value_datetime = DATE_FORMAT(o.obs_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
        write(update_query_encounter,file="fix_obs_encounter_anamnese_querys.txt",append=TRUE)
        write(update_query_obs,file="fix_obs_encounter_anamnese_querys.txt",append=TRUE)
      } else {
        if(ano_value < 2003){
          
          print(paste0(encounter_id, " Fluxo inesperado, rever manualmente unable to find startdate (", openmrs.db.name,") "))
          write(paste0(encounter_id, " Fluxo inesperado, rever manualmente unable to find startdate (", openmrs.db.name,") "),file="error_obs_encounter_apss_pp.txt",append=TRUE)
          
        } else {
          
          update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
          update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", ano_value ,"-%m-%d 00:00:00'), o.value_datetime = DATE_FORMAT(o.obs_datetime, '", ano_value ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
          write(update_query_encounter,file="fix_obs_encounter_anamnese_querys.txt",append=TRUE)
          write(update_query_obs,file="fix_obs_encounter_anamnese_querys.txt",append=TRUE)
          
        }
        
        
      }
      
      
    }
    
    
  }
  
  
}

