est_forms = \(data, dv, iv,
 controls = c("med_schools_ind", 
              "logww1",
              "verdun_petain",
              "palpha1935",
              "perrev1935",
              "etranger1935")){


  
lhs = data |>
  select({{dv}}) |>
  colnames()
  
rhs = data |>
  select({{iv}}, all_of(controls)) |>
  colnames()
  
form = reformulate(rhs, response = lhs)

# pc and clusters are based off of this 
# which was run on earlier work   



return(form)

}


