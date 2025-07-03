merge_camps = \(merge_data = 'archived_camps.csv', klarsdat ){

mergedata = rlang::englue('{merge_data}')  

archived_camps_raw = read_csv( here::here("data", mergedata)) |> 
  mutate(has_camp = 1) |> 
  select(camp_name, insee_numb, url, has_camp)


aggregated_camps  = archived_camps_raw |> 
  group_by(insee_numb) |> 
  summarise(total_camps = n(), 
            camp_name = paste(camp_name, collapse = ',')) 



## this maybe a little interesting since lord knows how well this went 
raw_klarsfeld = klarsdat 

merge_in_camps = raw_klarsfeld |> 
  left_join(aggregated_camps, join_by(insee_com == insee_numb)) |> 
  mutate(has_camp = ifelse(!is.na(camp_name), TRUE, FALSE))


write_csv(merge_in_camps,here::here("processed_dat",
                                    "klarsfeld_merged_with_2002_election_camps_add.csv"))
return(merge_in_camps)
}
