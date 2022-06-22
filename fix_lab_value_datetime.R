
# Ficha Laboratorio
#                               
#data do pedido < data resultado  
# 6246 - Pedido Lab

query_lab_vdt_prox <- "Select obs_id, person_id, identifier,substr(identifier,12,4) as year, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id left join patient_identifier pi on pi.patient_id = e.patient_id
Where YEAR( o.value_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and encounter_type = 13  and concept_id in (23821,6246) and o.voided =0 and pi.identifier_type=2 ;"

df_lab_vd <- getOpenmrsData(con_openmrs,query_lab_vdt_prox)

if(nrow(df_lab_vd)>0){
  
  for (i in 1:dim(df_lab_vd)[1]) {
    
    obs_id <- df_lab_vd$obs_id[i]
    encounter_id <- df_lab_vd$encounter_id[i]
    concept_id <- df_lab_vd$concept_id[i]
    ano_obs <- df_lab_vd$ano_obs[i]
    ano_value <- df_lab_vd$ano_value[i]
    encounter_created <- df_lab_vd$encounter_created[i]
    obs_datetime <- df_lab_vd$obs_datetime[i]
    value_datetime <- df_lab_vd$value_datetime[i]
    
    if (concept_id == 6246){
      
      if (ano_obs < 2000){
        # Do nothing
        
      } 
      else {
        
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        
        if (temp_vdt <= tmp_obs_datetime ){
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id, " ;")
          write(update_query_obs,file="fix_lab_value_datetime_querys.txt",append=TRUE)
        }
        else {
          # try with encounter_date
          temp_vdt    <-   as.Date( paste0(encounter_created,substr(value_datetime, 5,nchar(value_datetime)) ) )
          if (temp_vdt <= tmp_obs_datetime ){
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", encounter_created ,"-%m-%d 00:00:00') where obs_id = ", obs_id, " ;")
            write(update_query_obs,file="fix_lab_value_datetime_querys.txt",append=TRUE)
            
          } else {
            print(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "))
            write(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "),file="error_obs_encounter_apss_pp.txt",append=TRUE)
          }
          
        }
        
        
      }
      
    }
    else if(concept_id == 23821){
      
      if (ano_obs < 2000){
        # Do nothing
        
      } 
      else {
        
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        
        if (temp_vdt <= tmp_obs_datetime ){
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id, " ;")
          write(update_query_obs,file="fix_lab_value_datetime_querys.txt",append=TRUE)
          
        }
        else {
          # try with encounter_date
          temp_vdt    <-   as.Date( paste0(encounter_created,substr(value_datetime, 5,nchar(value_datetime)) ) )
          if (temp_vdt <= tmp_obs_datetime ){
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", encounter_created ,"-%m-%d 00:00:00') where obs_id = ", obs_id, " ;")
            write(update_query_obs,file="fix_lab_value_datetime_querys.txt",append=TRUE)
            
          } else {
            print(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "))
            write(paste0(encounter_id, " Fluxo inesperado, rever manualmente (", openmrs.db.name,") "),file="error_obs_encounter_apss_pp.txt",append=TRUE)
          }
          
        }
        
        
      }
      
    }
    
    
  }
  
}




