parallel_trends_graph = \(list_object, se = 'bootstrap', treat_name){

treats = rlang::englue('{treat_name}')

se = rlang::englue('{se}')

get_ests = list_object |>
pluck('ests')

plot_ests = within(get_ests, rm(`Matrix Completion`))

plot_results = synthdid_plot(plot_ests,
                          ci.alpha = 0,
                          effect.alpha = 0,
                          diagram.alpha = 0, 
               treated.name = treats,
               se.method = se) +
  AllenMisc::theme_allen_minimal() +
   theme(legend.position= 'top') +
   scale_color_met_d(name = 'Troy')

return(plot_results)

}