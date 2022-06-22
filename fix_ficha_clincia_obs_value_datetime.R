
# FICHA CLINICA (S.TARV: ADULTO SEGUIMENTO) 
#                               
# 1014 proxima consulta  



query_fc_all_prox <- "Select obs_id, person_id, identifier,substr(identifier,12,4) as year, o.encounter_id, concept_id, encounter_type, YEAR(obs_datetime) as ano_obs ,obs_datetime, /*DATE_FORMAT(obs_datetime,'2020-%m-%d 00:00:00'), */ value_datetime, 
year(value_datetime) as ano_value, e.encounter_datetime, /*DATE_FORMAT(e.encounter_datetime,'2020-%m-%d 00:00:00') ,*/ o.date_created , year(e.date_created) as encounter_created
From obs o inner join encounter e on o.encounter_id=e.encounter_id inner join patient_identifier pi on pi.patient_id = e.patient_id
Where YEAR( o.value_datetime) in ( select YEAR(obs_datetime) from obs where YEAR(obs_datetime)  < 1961 and voided=0 group by YEAR(obs_datetime) ) 
and encounter_type in (6,9) and o.voided =0 and e.voided=0 and pi.voided=0 and pi.identifier_type=2 ;"




df_fc_all <- getOpenmrsData(con_openmrs,query_fc_all_prox)


if(nrow(df_fc_all) > 0){
  for (i in 1:dim(df_fc_all)[1]) {
    
    obs_id <- df_fc_all$obs_id[i]
    
    encounter_id <- df_fc_all$encounter_id[i]
    
    obs_datetime <- substr(df_fc_all$obs_datetime[i],1,10)
    
    ano_obs <- df_fc_all$ano_obs[i]
    
    value_datetime <- df_fc_all$value_datetime[i]
    
    if(substr(value_datetime, 5,nchar(value_datetime)-9)=="-02-29"){
      value_datetime <- str_replace(string = value_datetime,pattern ="-02-29",replacement = "-02-28" )
    }
    
    encounter_datetime <- df_fc_all$encounter_datetime[i]
    concept_id <- df_fc_all$concept_id[i]
    encounter_created <- df_fc_all$encounter_created[i]
    
    if      (concept_id == 1410){
      
      if(ano_obs > 2000){
        
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)-9) ) )
        
        tmp_obs_datetime <-  as.Date(obs_datetime)
        if (temp_vdt < tmp_obs_datetime ){
          
          # add 1 year  and check if difference is less than 6 months
          ano_obs <- ano_obs+ 1
          temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
          
          if( as.integer(temp_vdt - tmp_obs_datetime) <= 190   ){
            
            
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
            write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
            
          } 
          else {
            
            print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
            write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
            
            
            
          }
          
        }
        else {
          
          
          if( as.integer(temp_vdt - tmp_obs_datetime) <= 190   ){
            
            
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
            write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
            
          } else {
            
            print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
            write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
            
            
          }
          
          
        }
        
      }
      else if (encounter_created>2000){
        
        
        temp_vdt    <-   as.Date( paste0(encounter_created,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_dt <-  as.Date( paste0(encounter_created,substr(obs_datetime, 5,nchar(value_datetime))) )
        
        if(temp_vdt > tmp_obs_dt ){
          
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", encounter_created ,"-%m-%d 00:00:00') ,  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created  ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;"  )
          update_query_all_enc<- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id , " ;"  )
          update_query_encounter <- paste0("update openmrs.encounter e  set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", encounter_created ,"-%m-%d 00:00:00')  where encounter_id = ", encounter_id , " ;"  )
          write(update_query_encounter,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          write(update_query_all_enc,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          
        } 
        else {
          
          
          
          temp_vdt    <-   as.Date( paste0(encounter_created +1,substr(value_datetime, 5,nchar(value_datetime)) ) )
          tmp_obs_dt <-  as.Date( paste0(encounter_created  ,substr(obs_datetime, 5,nchar(value_datetime))) )
          
          
          if( as.integer(temp_vdt - tmp_obs_dt) <= 190   ){
            
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", encounter_created +1 ,"-%m-%d 00:00:00') ,  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created  ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;"  )
            update_query_all_enc<- paste0("update openmrs.obs o set  o.obs_datetime = DATE_FORMAT(o.obs_datetime, '", encounter_created  ,"-%m-%d 00:00:00') where encounter_id = ", encounter_id , " ;"  )
            update_query_encounter <- paste0("update openmrs.encounter e  set  e.encounter_datetime = DATE_FORMAT(e.encounter_datetime, '", encounter_created  ,"-%m-%d 00:00:00')  where encounter_id = ", encounter_id , " ;"  )
            write(update_query_encounter,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
            write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
            write(update_query_all_enc,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
            
          }
          
          
        }
        
      }
      else {
        
        print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
        write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_value_datetime_fc.txt",append=TRUE)
        
        
      }
    }
    # DPP
    else if (concept_id == 6256){
      
      
      
      if(ano_obs > 2000){
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        if (temp_vdt < tmp_obs_datetime ){
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          
        }
        else {
          
          ano_obs = ano_obs -1
          temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
          
          if (temp_vdt < tmp_obs_datetime ){
            
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
            write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
            
          } else {
            
            print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
            write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
            
          }
          
        }
        
      }
      else{
        print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
        write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
        
      }
      
    }
    
    # Data provavel de parto
    else if (concept_id == 1600){
      
      
      
      if(ano_obs > 2000){
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        if (temp_vdt < tmp_obs_datetime ){
          
          ano_obs = ano_obs +1
          temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          
        }
        else {
          
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          
          
        }
        
      }
      else{
        print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
        write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
        
      }
      
    }
    
    # DUM
    else if (concept_id == 1465){
      
      
      
      if(ano_obs > 2000){
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        if (temp_vdt < tmp_obs_datetime ){
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          
        }
        else {
          ano_obs =ano_obs -1 
          temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
          tmp_obs_datetime <-  as.Date(obs_datetime)
          if (temp_vdt < tmp_obs_datetime ){
            
            update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
            write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
            
          } else {
            
            print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
            write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
            
          }
          
        }
        
      }
      else{
        print( paste0("Fluxo nao previsto, prox. consulta FC concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ))
        write( paste0("Fluxo nao previsto, prox. consulta FC  concept = ",concept_id, " encounter_id = ", encounter_id, "(",  openmrs.db.name,")"  ),file="error_obs_encounter_apss_pp.txt",append=TRUE)
        
      }
      
    }
    
    # data de inico de profilaxia com ctz & INH
    else if (concept_id %in%  c(6128,6126,6126) ){
      
      if(ano_obs > 2000){
        
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)-9) ) )
        
        tmp_obs_datetime <-  as.Date(obs_datetime)
        
        if (temp_vdt > tmp_obs_datetime ){
          
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs -1 ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
        } else {
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs  ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
        }
      } else {
        
        
        update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", encounter_created  ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
        write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
      }  
      
      
      
    }
    
    # data de inico TARV
    else if (concept_id %in% c(1190,1113) ){
      
      
      if(ano_obs > 2000){
        
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)-9) ) )
        
        tmp_obs_datetime <-  as.Date(obs_datetime)
        
        if (temp_vdt > tmp_obs_datetime ){
          
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs -1 ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
        } else {
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs  ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
        }
      } else {
        
        
        update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", encounter_created  ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
        write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
      }  
      
      
      
    }
    
    
    # Data do proximo CD4
    else if (concept_id == 6249){
      
      if(ano_obs > 2000){
        temp_vdt    <-   as.Date( paste0(ano_obs,substr(value_datetime, 5,nchar(value_datetime)) ) )
        tmp_obs_datetime <-  as.Date(obs_datetime)
        if (temp_vdt > tmp_obs_datetime ){
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          
        }
        else {
          
          
          update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", ano_obs + 1 ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
          write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
          
          
        }
        
      }
      else{
        update_query_obs <- paste0("update openmrs.obs o set  o.value_datetime = DATE_FORMAT(o.value_datetime, '", encounter_created  ,"-%m-%d 00:00:00') where obs_id = ", obs_id , " ;")
        write(update_query_obs,file="fix_ficha_clinica_value_datetime_querys.txt",append=TRUE)
        
      }
      
    }
    
    else {
      # No other concept_ids where found
    }
    
    
  }
  
}
