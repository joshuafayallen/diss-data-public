create_panel = \(data_longer, election_vars =
  c("sh_nuance_extreme_droite_19",
"sh_nuance_extreme_droite_24", "sh_nuance_extreme_droite_32",
"sh_nuance_extreme_droite_14", "sh_nuance_extreme_droite_36")){
## lets trigger a restart of the process
  

longerklarsfeld = data_longer |> 
  pivot_longer(cols = all_of(election_vars),
               values_to = "far_right_vote_share_prewar",
               names_to = "election_year") |> 
  mutate(year = str_extract(election_year, '\\d+$'),
year =case_match(year,
                                '14' ~ '1914',
                                '19' ~ '1919',
                                '24' ~ '1924',
                                '32' ~ '1932',
                                '36' ~ '1936', .default = year),
         year = as.numeric(year),
         ## broadly this will do the same thing as examp_date = c("1914-11-24")
         ## year(examp_date) |> class()
         after_36 = ifelse(year > 1936, TRUE, FALSE),
         treat_ind_plot  = ifelse(treat_ind == TRUE, TRUE, FALSE),
         has_camp_plot = ifelse(has_camp == TRUE, TRUE, FALSE),
         treat_ind = ifelse(treat_ind == TRUE & after_36 == TRUE, TRUE, FALSE),
         has_camp = ifelse(has_camp == 1 & after_36 == TRUE, TRUE, FALSE),
        across(where(is.character), \(x) iconv(x, from = 'latin1', to = 'UTF-8'))) |> 
  group_by(id_geofla) |> 
  arrange(year, .by_group = TRUE) |> 
  ungroup()

if(dir.exists('processed_panel_data')){
  longerklarsfeld |> 
    group_by(year) |> 
    write_dataset(path = 'processed_panel_data')
}else{
  dir.create('processed_panel_data')

  longerklarsfeld |> 
    group_by(year) |> 
    write_dataset(path = 'processed_panel_data')
}

return(longerklarsfeld)                                             

}



