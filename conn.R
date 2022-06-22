# Packages que contem algumas funcoes a serem usadas. Deve-se  garantir que tem todos os packages instalados.
# Para instalar deve: ligar o pc a net e  na consola digitar a instrucao -  ex: install.packages("plyr") depois install.packages("stringi ") assim sucessivamente
require(RMySQL)
require(plyr)    
require(stringi)
require(stringr)
require(tidyr)
require(dplyr)  
require(writexl)

#' Busca dados de uma query enviada a openmrs
#'
#' @param con.postgres  obejcto de conexao com BD OpenMRS
#' @return tabela/dataframe/df com todos paciente do OpenMRS
#' @examples patients_idart <- getAllPatientsIdart(con_openmrs)
getOpenmrsData <- function(con.openmrs, query) {
  rs  <- dbSendQuery(con.openmrs,query)
  data <- fetch(rs, n = -1)
  dbClearResult(rs)
  return(data)
  
}

