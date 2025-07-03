make_weights = \(data_obj, wt_method = c( 'bart','ebal',  'cbps', 'gbm'), treat, 
selecting_var = c("med_schools_ind", "wheat_suit", "logww1", "verdun_petain", "palpha1935", "perrev1935", "etranger1935"),
 estimand = 'ATT', it = 20000, ..., spatial_var){


    
relg_verdun_elect_share = data_obj |>
   select(all_of(selecting_var)) |>
   colnames()

treat_name = rlang::englue('{{treat}}')

forms = reformulate(relg_verdun_elect_share, response = treat_name)

est = rlang::englue('{estimand}')

spat_var = rlang::englue('{{spatial_var}}')

data_obj = data_obj |>
   drop_na('pvoix_lepen_2002') |>
   select(all_of(selecting_var), {{treat}})




  all_weights  = map(wt_method, \(x) weightit(forms, data = data_obj,
                                             method = x, estimand = est, maxit = it,
   ...))


names(all_weights) = wt_method
  





return(all_weights)
}








