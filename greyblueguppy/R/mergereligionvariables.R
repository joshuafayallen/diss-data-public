merging_religion = \(merge_data = "4.district_dataset.dta", klarsdat){
    
    
    communes_france = read_sf(here::here(
                                                     "shp-files",
                                                     "communes.geojson"))|> 
  janitor::clean_names() |> 
  filter(nom_reg != "CORSE") |> 
  select(id_geofla, geometry)


mergedata = rlang::englue('{merge_data}')

klarsfeld_raw = klarsdat

joined_geo = klarsfeld_raw |> 
  left_join(communes_france, join_by(id_geofla)) |> 
  st_set_geometry('geometry')






district_shp = read_sf(here::here("squicciarini", "districts.geojson")) |> 
  janitor::clean_names()


districts_data = haven::read_dta(here::here("squicciarini", mergedata))




joined_data = district_shp |> 
  left_join(districts_data, join_by(district_i == district_id)) 


joined_data = joined_data |> 
  select(-c( department_name, department_id,
            department_name))



options(sf_column_name_limit = 300)

write_sf(joined_data, here::here("data","squicciarini_data.geojson"))


##  we are going to have to change these since write_sf is annoying 

og_names = colnames(joined_data)

og_names = og_names[-3]







squir = read_sf(here::here("data","squicciarini_data.geojson")) 

names_look_up = colnames(squir)[-16]

look_up_tib  = tibble(new_name = og_names,
                      old_names = names_look_up) |> 
  deframe()


cols_rename = squir |> 
  rename(!!!look_up_tib) 




## ahhh the issue is that the share refactory clergy is actually not 
## at the commune level it is at the canton level 
## meaning that the level of aggregation is a bit higher. This is forsure not a 
## a small issue 



## lets set largest to true it looks like https://github.com/r-spatial/sf/issues/578
## basically it is joining the polygons based on the largest amount of overlap 
## which makes sense? 


joining_klarsfeld_religion = joined_geo |> 
  st_join(cols_rename, largest = TRUE)




## okay it looks like we are cooking! 


## lets keep this a little bit seperate 

saving_dataset = joining_klarsfeld_religion |> 
  st_drop_geometry() |> 
  janitor::clean_names() |> 
  mutate(treat_ind = ifelse(is.na(treat_ind), FALSE, TRUE)) |>
  mutate(across(where(is.character), \(x) iconv(x, from = 'latin1', to = 'UTF-8')))







return(saving_dataset)


}
