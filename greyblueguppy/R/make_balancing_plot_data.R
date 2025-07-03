asses_balance = \(weights_list, treat_name){

  weight_names = map(weights_list, \(x) pluck(x, 'method')) 
  
  weights_tibble = tibble(methods = weight_names) |> 
    unnest(methods)
  
  
  names(weights_list) = weights_tibble$methods
  
  weights_tibble$weighitlists = weights_list
  
  add_plots = weights_tibble |> 
    mutate(plots = map2(weighitlists, methods ,\(x,y) cobalt::love.plot(x,  drop.distance = TRUE,abs = TRUE, thresholds = c(m = .1)))) |> 
    pull('plots')
  
  
  grab_datas = map(add_plots, \(x) ggplot_build(x)) %>%
    map(., \(x) pluck(x,'plot', 'data')) |> 
    list_rbind(names_to = 'balance_method')  |>
    mutate(treat_name := rlang::englue('{{treat_name}}'),
          clean_methods = ifelse(Sample == 'Unadjusted', "Unadjusted", balance_method),
          clean_methods = case_match(clean_methods,
          "glm" ~ "Propensity Score",
          "ebal" ~ "Entropy",
          'super' ~ "Super Learner",
          'gbm' ~ "Gradient Boosting",
          'bart' ~ 'BART',
          'ipt' ~ 'IP Tilting', .default = clean_methods),
          clean_labs = glue::glue('{clean_methods} Weights'))

    if(!dir.exists(paste('balancing_plots_data', "/",rlang::englue("{{treat_name}}")))){
        dir.create(paste0('balancing_plots_data', "/", rlang::englue("{{treat_name}}")))
    }else{
        print('directory already exists')
    }
 


     grab_datas |>
     group_by(balance_method) |> 
     write_dataset(path =paste0('balancing_plots_data', "/", rlang::englue("{{treat_name}}")))

    return(grab_datas)
  
  }
