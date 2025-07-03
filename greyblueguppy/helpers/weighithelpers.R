

creating_controls = \(data,controls = NULL,  y = NULL, z = NULL){
  if(!isTRUE(is.character(controls))){
    stop(paste0("Controls must be a character vector"))
    
  }
  if(!is.null(y) & !isTRUE(is.character(y))){
    stop(paste0("y must be a character vector"))
    
  }
  
  if(!is.null(z) & !isTRUE(is.character(z))){
    stop(paste0("y must be a character vector"))
    
  }
  
  if(is.null(y)){
    controls_dataset = data |>
      select(all_of(controls)) |>
      colnames()
    
    return(controls_dataset)
    
    
  } 
   if(is.null(z)){
     
     controls = c(controls, y)
     
     controls_data =  data |>
       select(all_of(controls)) |>
       colnames()
     
     return(controls_data)
     
   }
  
    else {
    controls = c(controls, y, z)
    
    controls_data =  data |>
      select(all_of(controls)) |>
      colnames()
    
    return(controls_data)
  }
  
  
}


get_dta = \(links, path = 'piketty-cage-data'){

  path = rlang::englue('{path}')

  if(!dir.exists(path)){

  dir.create(path)

  temp = tempfile()

  download.file(links, temp)

  unzip(zipfile = temp, exdir = path)

}else{
    
  temp = tempfile()

  download.file(links, temp)

  unzip(zipfile = temp, exdir = path)
    
  }
  return(print('downloaded data'))
}
