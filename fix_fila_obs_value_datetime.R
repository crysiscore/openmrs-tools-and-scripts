
# Fila
#                               
# 5096 proxima consulta  



query_fila_all_prox <- "Select obs_id, person_id, identifier,substr(identifier,12,4) as year, o.encounter_id, concept_id, encounter_type, e.form_id, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id left join patient_identifier pi on pi.patient_id = e.patient_id
Where YEAR( o.value_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and encounter_type =18 and o.voided =0 and pi.identifier_type=2 ;"



df_fila_all <- getOpenmrsData(con_openmrs,query_fila_all_prox)


if(nrow(df_fila_all)>0 ){
  for (i in 1:dim(df_fila_all)[1]) {
    
    
    obs_id <- df_fila_all$obs_id[i]
    encounter_id <- df_fila_all$encounter_id[i]
    obs_datetime <- df_fila_all$obs_datetime[i]
    ano_obs <- df_fila_all$ano_obs[i]
    value_datetime <- df_fila_all$value_datetime[i]
    encounter_datetime <- df_fila_all$encounter_datetime[i]
    form_id <- df_fila_all$form_id[i]
    encounter_created <- df_fila_all$encounter_created[i]
    concept_id <- df_fila_all$concept_id[i]
    
    if      (form_id == 130){
      
      
      if(ano_obs > 2000){
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        if (temp_vdt < tmp_obs_datetime ){
          
          # add 1 year  and check if difference is less than 6 months
          ano_obs <- ano_obs+ 1
          temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
          
          if( as.integer(temp_vdt - tmp_obs_datetime) < 190   ){
            
            
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
            write(update_query_obs,file="fix_fila_value_datetime_querys.txt",append=TRUE)
            
          } else {
            
            print( paste0("Fluxo nao previsto, prox. consulta Fila concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
            write( paste0("Fluxo nao previsto, prox. consulta Fila  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
            
            
            
          }
          
        } 
        else {
          
          
          if( as.integer(temp_vdt - tmp_obs_datetime) <= 190   ){
            
            
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
            write(update_query_obs,file="fix_fila_value_datetime_querys.txt",append=TRUE)
            
          } else {
            
            print( paste0("Fluxo nao previsto, prox. consulta Fila concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
            write( paste0("Fluxo nao previsto, prox. consulta Fila  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
            
            
          }
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_fila_value_datetime_querys.txt",append=TRUE)
          
          
          
        }
        
      }
      else {
        
        print( paste0("Fluxo nao previsto, prox. consulta Fila concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
        write( paste0("Fluxo nao previsto, prox. consulta Fila  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
        
        
      }
      
    } 
    else {
      
      print( paste0("Fluxo nao previsto outro form, prox. consulta Fila concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
      write( paste0("Fluxo nao previsto outro form, prox. consulta Fila  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
      
      
      
    }
    
    
    
  }
  
  
}
