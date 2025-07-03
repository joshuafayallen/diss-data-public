estimate_models_deport = \(weighit_obj, treat_name, your_data){

treat_name = rlang::englue('{{treat_name}}')

controls =  c("sh_nuance_extreme_gauche_36", "sh_nuance_gauche_36",  "sh_nuance_centre_gauche_36" ,  "sh_nuance_centre_droit_36" ,  "sh_nuance_droite_36" , "sh_nuance_extreme_droite_36" , "sh_nuance_extreme_gauche_32", "sh_nuance_gauche_32", "sh_nuance_centre_gauche_32" ,  "sh_nuance_centre_droit_32" , "sh_nuance_droite_32" , "sh_nuance_extreme_droite_32" ,  "med_schools_ind" , "wheat_suit", "verdun_petain", "logww1" , "share_refractory")

rhs = c(treat_name, controls)
  
est_data = your_data |>
  drop_na('le_pen_vote_share')


g_form = reformulate(rhs, response = 'le_pen_vote_share')

bivariate = reformulate(treat_name, response = 'le_pen_vote_share')

bivariate_estimation = map(weighit_obj, \(x) lm_weightit(bivariate, data = est_data, weightit = x, vcov = 'none'))

corrected_se = map(bivariate_estimation, \(x) lmtest::coeftest(x, vcovFWB(x, cluster = ~id_geofla, R = 1000))) |>
  list_rbind(names_to = 'weighting_method') |>
  mutate(estimation_method = 'Weighted Bivariate OLS')

g_comps = map(weighit_obj, \(x) lm_weightit(g_form, data = est_data, weightit = x, vcov = 'none'))

processed_g = map(g_comps, \(x) marginaleffects::avg_comparisons(x, variables = treat_ind , newdata = subset(treat_ind == TRUE))) |>
  list_rbind(names_to = 'weighting_method') |>
    mutate(estimation = 'G-Estimation') |>
      select(weighting_method, estimation, term, estimate, std.error, conf.low, conf.high)
    
plot_dat = bind_rows(corrected_se, processed_g)


write_parquet(plot_dat, 'estimation_results/deport/results_deport.parquet')

  


return(plot_dat)

}



