## this will implement the BART heterogeneity analysis
## adding this so I trick targets

bart_sens = \(bart_dat, treatment, dv, burnin = 11000, controls = c( 
  "med_schools_ind","wheat_suit","logww1","verdun_petain","palpha1935","perrev1935","etranger1935")){
  
dv_name = rlang::englue('{{dv}}')                 

klarsfeld_data  = bart_dat  |>
drop_na({{dv}}) 
    
  

relg_verdun_elect_share = creating_controls(bart_dat, controls,
  y = "logww1", z = "verdun_petain")

treat_name = rlang::englue('{{treatment}}')

forms = reformulate(relg_verdun_elect_share, response = treat_name)

bart_weights = weightit(forms, data = klarsfeld_data, method = 'bart', estimand = 'ATT')


small_klarsfeld = klarsfeld_data |>
select({{treatment}}, {{dv}},  all_of(relg_verdun_elect_share)) |>
  mutate(ipw = bart_weights$weights,
         {{dv}} := {{dv}} * 100) |>
as.data.frame()


# small_klars_add_dummies = dummy_cols(small_klarsfeld, select_columns = 'id_geofla')
# 
# small_klars_add_dummies = small_klars_add_dummies |>
# select(-id_geofla)

### 


te_model = BART::wbart(x.train = select(small_klarsfeld,
                   -c({{dv}})),
                 y.train = pull(small_klarsfeld,
                  {{dv}}),
                  nskip = burnin)




extract_sigma = tidytreatment::variance_draws(te_model, value = "sigma_square", ) |>
mutate(sigma = sqrt(sigma_square)) |>
## drop everything in the warmup 
filter(.draw > burnin)

write_parquet(extract_sigma, here::here('bart_analysis', paste0("variance_draw_", treat_name,'_', dv_name,".parquet")))

posterior_pred = tidybayes::add_predicted_draws(object = te_model,  include_newdata = FALSE)

write_parquet(posterior_pred, here::here("bart_analysis", paste0('poster_predictions_',
treat_name,'_',dv_name,".parquet")))


posterior_fitted = tidybayes::add_fitted_draws(model = te_model, value = 'fitted', include_newdata = FALSE)

write_parquet(posterior_fitted, here::here('bart_analysis', paste0("posterior_fitted_",
treat_name,'_',dv_name,".parquet")))


att = tidytreatment::treatment_effects(te_model, treatment = treat_name ,
      subset = 'treated', newdata = small_klarsfeld) |>
  mutate(imputed = FALSE)


write_parquet(att, here::here("bart_analysis", paste0("posterior_conditional_att_", treat_name,'_',dv_name,".parquet")))

return(te_model)

}
