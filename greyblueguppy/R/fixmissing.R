
clean_past_elections = \(relg_data, elections_ctrols =c("sh_nuance_extreme_gauche_32", "sh_nuance_extreme_gauche_36", 
"sh_nuance_extreme_droite_32", "sh_nuance_extreme_droite_36",
"sh_nuance_droite_32", "sh_nuance_droite_36",
"sh_nuance_centre_gauche_32", "sh_nuance_centre_gauche_36",
"sh_nuance_centre_droit_32", "sh_nuance_centre_droit_36",
"sh_nuance_gauche_32", "sh_nuance_gauche_36") ){

### okay  I am going to have to 

cleaned_analysis_data = relg_data |>
mutate(across(all_of(elections_ctrols), \(x) ifelse(is.na(x), 0, x) ))


arrow::write_parquet(cleaned_analysis_data, here::here("processed_dat", "balancing_dataset_add_religion.parquet"
))

return(cleaned_analysis_data)


}