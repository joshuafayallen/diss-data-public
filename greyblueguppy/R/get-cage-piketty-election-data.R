get_historic_data_election = \(links_prefix = 'https://conflit-politique-data.ams3.cdn.digitaloceanspaces.com/zip/pres'){

  links_dat = tibble(links = c(paste0(links_prefix, '1965', '_', 'dta.zip'), 
  paste0(links_prefix, '1969', '_', 'dta.zip'), paste0(links_prefix, '1971', '_', 'dta.zip'),  paste0(links_prefix, '2022', ' ', 'dta.zip') )) 
    
  links_two  = tibble(links = paste0(links_prefix, seq(1981, 2022, by = 7), '_', 'dta.zip')) |>
    bind_rows(links_dat)
  
  links_with_files = links_two |>
    mutate(year = str_extract(links, '\\d{4}'),
          file_name = paste0('pres', year, 'comm', '.dta'))
  
  links_with_files$file_name[1]
  
  
  links_two  = tibble(links = paste0(links_prefix, seq(1981, 2022, by = 7), '_', 'dta.zip'))  |>
    bind_rows(links_dat) |>
      mutate(year = str_extract(links, '\\d{4}'),
             links = case_when(year == '2009' ~ 'https://conflit-politique-data.ams3.cdn.digitaloceanspaces.com/zip/pres2007_dta.zip',
                               year == '2016' ~ 'https://conflit-politique-data.ams3.cdn.digitaloceanspaces.com/zip/pres2017_dta.zip', .default = links)) |>
    pull('links')
    
    
    map(links_two, \(x) get_dta(links = x))
  
  
  
return(links_two)

}



