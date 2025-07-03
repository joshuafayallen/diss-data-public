add_weights_cs = \(weighting_data, rhs, lhs){

  form = reformulate(rhs, response = lhs)

  weights = WeightIt::weightit(form, data = weighting_data,
  method = 'bart', estimand = 'ATT')

  add_weights = weighting_data |>
    mutate(weights = weights$weights)

  return(add_weights)


}