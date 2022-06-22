
# FICHA DE REGISTO PARA RASTREIO DO CANCRO DO COLO UTERINO
#                               
# data rastreio = encounterdate  
# 1065 -DUM
# 23967 Data da realização da crioterapia em
# 23968 Data da próxima consulta:


query_ccu_obsdt_prox <- "Select obs_id, person_id, identifier,substr(identifier,12,4) as year, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id left join patient_identifier pi on pi.patient_id = e.patient_id
Where YEAR( o.obs_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and encounter_type = 28  and concept_id in (1465,2119,23967,23968) and o.voided =0 and pi.identifier_type=2 ;"

query_ccu_vdt_prox <- "Select obs_id, person_id, identifier,substr(identifier,12,4) as year, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id left join patient_identifier pi on pi.patient_id = e.patient_id
Where YEAR( o.value_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and encounter_type = 28  and concept_id in (1465,2119,23967,23968) and o.voided =0 and pi.identifier_type=2 ;"

df_ccu_obsdt <- getOpenmrsData(con_openmrs,query_ccu_obsdt_prox)
df_ccu_vdt <- getOpenmrsData(con_openmrs,query_ccu_vdt_prox)

if(nrow(df_ccu_obsdt)){
  for (i in 1:dim(df_ccu_obsdt)[1]) {
    
    encounter_id <- df_ccu_obsdt$encounter_id[i]
    encounter_created <- df_ccu_obsdt$encounter_created[i]
    
    
    update_query_obs <- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id , " ;")
    update_query_encounter <- paste0("update openmrs.encounter e set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id, " ;")
    write(update_query_obs,file="fix_ccu_value_datetime_querys.txt",append=TRUE)
    
    
    
  }
  
}
  
if(nrow(df_ccu_vdt) > 0){
  for (i in 1:dim(df_ccu_vdt)[1]) {
    
    ano_obs <- df_ccu_vdt$ano_obs[i]
    encounter_created <- df_ccu_vdt$encounter_created[i]
    obs_datetime <- df_ccu_vdt$obs_datetime[i]
    value_datetime <- df_ccu_vdt$value_datetime[i]
    encounter_datetime <- df_ccu_vdt$encounter_datetime[i]
    encounter_id <- df_ccu_vdt$encounter_id[i]
    concept_id <- df_ccu_vdt$concept_id[i]
    
    
    if (concept_id == 1465){
      
      
      
      if(ano_obs > 2000){
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        if (temp_vdt < tmp_obs_datetime ){
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id , " ;")
          write(update_query_obs,file="fix_ccu_value_datetime_querys.txt",append=TRUE)
          
        }
        
      }
    } else {
      
      print(paste0("Fluxo nao previsto, CCU concept = ",concept_id, " encounter_id = ", encounter_id ))
    }
    
  }
  
  
}


