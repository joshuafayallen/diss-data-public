make_imputed_weights = \(data, methods = c('bart','ebal', 'cbps', 'gbm'), treat_name,
                         selecting_var = c("med_schools_ind", "wheat_suit",
                                           "logww1", "verdun_petain", "palpha1935",
                                           "perrev1935", "etranger1935"),
                         dvs = c('pvoix_tixiervignancour_1965', 'pvoix_lepen_2002'),
                         spatial_var,
                         estimand = 'ATT', it = 20000, ...){


relg_verdun_elect_share = data |>
      select(all_of(selecting_var)) |>
      colnames()

smaller_data = data |>
   select(all_of(selecting_var), {{treat_name}}, all_of(dvs), {{spatial_var}})

spat_var = rlang::englue('{{spatial_var}}')


imputed_data = mice::mice(smaller_data)
 
treatment = rlang::englue('{{treat_name}}')

est = rlang::englue('{estimand}')

weights_form = reformulate(relg_verdun_elect_share, response = treatment)
  
weights_imputed = map(methods, \(mth) MatchThem::weightthem(weights_form, data = imputed_data,
                                                            method = mth,
                                                            approach = 'within',
                                                            estimand = est, maxit = it, ...))
  


names(weights_imputed) = methods  



return(weights_imputed)
} 
