


workin_dir <- '/home/agnaldo/Git/fix_openmrs_dates'

setwd(workin_dir)

source("conn.R")


vec_us <- c( "1_junho", "1_maio" ,"albasine","altomae","bagamoio","catembe",
             "cimento", "hpi", "hulene","incassane","inhaca","inhagoia" ,"josemacamo",
             "josemacamo_hg","magoanine_A","magoanine_tenda","malhangalene","mavalane_cs","mavalane_hg_a",
             "mavalane_hg_p","maxaquene","pescadores","polana_canico","porto","zimpeto","romao" )

vec_tmp = c("romao","xipamanine","zimpeto" )
vec_scripts <- c('fix_avaliacao_apss_pp_inicial.R', 'fix_apss_pp_encounter_dt.R',
                'fix_apss_pp_obs_datetime.R','fix_apss_pp_value_datetime.R' ,'fix_ccu_obs_datetime.R','fix_ficha_clincia_obs_value_datetime.R',
                'fix_fila_obs_value_datetime.R','fix_lab_value_datetime.R','fix_osb_anamesse_parte_a_adulto.R')

vec_scripts <-c('fix_ficha_clincia_obs_value_datetime.R')

## OpenMRS  - Configuracao de variaveis de conexao 
openmrs.user ='root'                         # ******** modificar
openmrs.password='password'                      # ******** modificar
                                               # ******** modificar
openmrs.host='192.168.1.10'                    # ******** modificar
openmrs.port=5457                              # ******** modificar


for (us in vec_us) {
  
  openmrs.db.name=us 
  # Objecto de connexao com a bd openmrs
  con_openmrs = dbConnect(MySQL(), user=openmrs.user, password=openmrs.password, dbname=openmrs.db.name, host=openmrs.host, port=openmrs.port)
  if( exists('con_openmrs')){
    dir_to_create <-  paste0(workin_dir,"/",us)
    if(!dir.exists(dir_to_create)){
      dir.create(path =dir_to_create,showWarnings = TRUE)
    }
    
    setwd(dir_to_create)
  

    for (script in vec_scripts) {
      print(paste0("----------------------------------     ", us, "    ---------------------------------------"))
      print(paste0("Executing script ",script))
      source(file = paste0('../',script))
      
    }
    
    dbDisconnect(con_openmrs)
    rm(con_openmrs)
  }
 
  
} 

