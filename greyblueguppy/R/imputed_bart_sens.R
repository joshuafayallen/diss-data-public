## this will implement the BART heterogeneity analysis
## adding this so I trick targets

bart_sens_imp = \(weight_obj, treatment, dv, burnin = 11000, controls = c( 
  "med_schools_ind","wheat_suit","logww1","verdun_petain","palpha1935","perrev1935","etranger1935")){

treat_name = rlang::englue('{{treatment}}')
dv_name = rlang::englue('{{dv}}')      

bart_dat = weight_obj$bart  |>
  complete() |>
  select(all_of(controls), {{dv}}, {{treatment}}) |> 
  mutate({{dv}} := {{dv}} * 100) |> 
  as.data.frame()


te_model = BART::wbart(x.train = select(bart_dat,
                   -c({{dv}})),
                 y.train = pull(bart_dat,
                  {{dv}}),
                  nskip = burnin)


extract_sigma = tidytreatment::variance_draws(te_model, value = "siqsq" ) |>
## drop everything in the warmup 
filter(.draw > burnin)

write_parquet(extract_sigma, here::here('bart_analysis', paste0('imputed_',"variance_draw_", treat_name,'_', dv_name,".parquet")))

posterior_pred = tidybayes::add_predicted_draws(object = te_model,  include_newdata = FALSE)

write_parquet(posterior_pred, here::here("bart_analysis", paste0('imputed_','poster_predictions_',
treat_name,'_', dv_name,".parquet")))


posterior_fitted = tidybayes::add_fitted_draws(model = te_model, value = 'fitted', include_newdata = FALSE)

write_parquet(posterior_fitted, here::here('bart_analysis', paste0("posterior_fitted_",
treat_name,'_', dv_name,".parquet")))


att = tidytreatment::treatment_effects(te_model, treatment = treat_name ,
      subset = 'treated', newdata = bart_dat)  |>
  mutate(imputed = TRUE)


write_parquet(att, here::here("bart_analysis", paste0("imputed_posterior_conditional_att_", treat_name,'_', dv_name ,".parquet"))) 

return(te_model)

}
