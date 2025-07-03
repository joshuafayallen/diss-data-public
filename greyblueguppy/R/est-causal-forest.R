forest_estimation = \(data, controls = c("med_schools_ind", "wheat_suit", "logww1", "verdun_petain", "palpha1935", "perrev1935", "etranger1935"), dv, treat){


causal_forest_data = data |>
  select(all_of(controls), {{dv}}, {{treat}}) |>
  drop_na({{dv}})


out = grf::causal_forest(Y = pull(causal_forest_data, {{dv}}),
                  X = causal_forest_data[,controls],
                  W = pull(causal_forest_data, {{treat}}), 
                  tune.parameters = 'all')


return(out)

}
