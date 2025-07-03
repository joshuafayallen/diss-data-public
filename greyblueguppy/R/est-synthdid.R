## so we don't retrigger the synthid deport target 

synthdid_estimate = \(panel_data, 
  missing_vars = c('far_right_vote_share'),
  selecting_vars = c("sh_nuance_gauche_14_nomiss", "sh_nuance_centre_gauche_14_nomiss",
                     "sh_nuance_centre_droit_14_nomiss", "sh_nuance_droite_14_nomiss",
                     "sh_nuance_extreme_gauche_19", "sh_nuance_gauche_19",
                     "sh_nuance_centre_droit_19", "sh_nuance_droite_19",
                     "verdun_petain",
                     "logww1",
                     "palpha1901",
                     "palpha1902","palpha1903","palpha1904","palpha1905","palpha1906",
                     "palpha1907","palpha1908","palpha1909","palpha1910","palpha1911",
                     "palpha1912","palpha1913","palpha1914","palpha1915","palpha1916",
                     "palpha1917","palpha1918","palpha1919","palpha1920","palpha1921",
                     "palpha1922","palpha1923","palpha1924","palpha1925","palpha1926",
                     "palpha1927","palpha1928","palpha1929","palpha1930","palpha1931",
                     "palpha1932","palpha1933","palpha1934","palpha1935","palpha1936",
                     "palpha1937","palpha1938","palpha1939", "perrev1919","perrev1920","perrev1921","perrev1922",
                     "perrev1923","perrev1924","perrev1925","perrev1926","perrev1927",
                     "perrev1928","perrev1929","perrev1930","perrev1931",
                     "perrev1932","perrev1933","perrev1934","perrev1935",
                     "perrev1936","perrev1937","perrev1938","perrev1939","recette1911","recette1920",
                     "etranger1919","etranger1920",
                     "etranger1921","etranger1922","etranger1923","etranger1924",
                     "etranger1925","etranger1926","etranger1927","etranger1928",
                     "etranger1929","etranger1930","etranger1931","etranger1932",
                     "etranger1933","etranger1934","etranger1935","etranger1936","etranger1937","etranger1938","etranger1939"),
  unit_name = id_geofla, date_col = 'year', treat_name,
   dv_name = far_right_vote_share, number_of_bootstraps = 500, path = c("synthdid-est/"), se_used = 'bootstrap'){


  
time_name = rlang::englue('{date_col}')


smaller_klarsfeld = panel_data |>
as_tibble() |> 
select({{unit_name}}, all_of(time_name), {{dv_name}}, {{treat_name}},
        all_of(selecting_vars)) |> 
  as.data.frame()



deport_path = 'deport'

camp_path = 'camp'
  
camp_path = rlang::englue('{camp_path}')

deport_path = rlang::englue('{deport_path}')

balanced_panel = BMisc::makeBalancedPanel(smaller_klarsfeld,
                                           idname = "id_geofla",
                                           tname = "year",
                                          return_data.table = TRUE) 

treatment = rlang::englue("{{treat_name}}")

se_type = rlang::englue('{se_used}')

spatial_var = rlang::englue('{{unit_name}}')

time_name = rlang::englue('{date_col}')


dv = rlang::englue('{{dv_name}}')


  

results = panel_estimate(balanced_panel,
unit_id = spatial_var,
time_id = time_name,
treatment = treatment,
outcome = dv,
mccores = 8,
reps = number_of_bootstraps,
infmethod = se_type)

## since this is really internal we can just add the directory here

if (!dir.exists(path)) {
    dir.create(path)
  }

  if (treatment == 'treat_ind') {
    if (!dir.exists(paste0(path, deport_path))) {
      dir.create(paste0(path, deport_path))
    }
    
    results_summary <- results$summary_table
    clean_results <- as_tibble(results_summary) %>%
      rownames_to_column(var = "stat") %>%
      mutate(stat = ifelse(stat == 1, "estimate", "standard_error"))

    cleaner_results <- pivot_longer(clean_results, cols = -stat, names_to = "estimator", values_to = "value") %>%
                       pivot_wider(names_from = 'stat', values_from = 'value', id_cols = 'estimator')

    write_parquet(cleaner_results, here::here(path, paste0(deport_path), "deport.parquet"))
  } else {
    if (!dir.exists(paste0(path, camp_path))) {
      dir.create(paste0(path, camp_path))
    }
    
    results_summary <- results$summary_table
    clean_results <- as_tibble(results_summary) %>%
      rownames_to_column(var = "stat") %>%
      mutate(stat = ifelse(stat == 1, "estimate", "standard_error"))

    cleaner_results <- pivot_longer(clean_results, cols = -stat, names_to = "estimator", values_to = "value") %>%
                       pivot_wider(names_from = 'stat', values_from = 'value', id_cols = 'estimator')

    write_parquet(cleaner_results, here::here(path, paste0(camp_path), "camp.parquet"))
  }

  return(results)
}


