merging_med_schools = \(merging_data = "klarsfeld_merged_with_2002_election_camps_add.csv",
                        klarsdat){
  
med_schools_raw = read_csv(here::here("data", "geocoded_med_schools.csv"))


med_schools_sf = med_schools_raw |> 
  st_as_sf(coords = c("long", "lat"), crs = st_crs("EPSG:4326"))


## lets use the same base as the klarsfeld 
communes_france = communes_cage = read_sf(here::here(
                                                     "shp-files",
                                                     "communes.geojson"))|> 
  janitor::clean_names() |> 
  filter(nom_reg != "CORSE") |> 
  select(id_geofla, geometry)


mergedata = rlang::englue('merging_data')

klarsfeld_raw = klarsdat

joined_geo = klarsfeld_raw |> 
  left_join(communes_france, join_by(id_geofla)) |> 
  st_set_geometry('geometry')

 

med_schools_sf = med_schools_sf |> 
  st_transform(crs = st_crs(joined_geo))


joined_med_schools = med_schools_sf |> 
  st_join(communes_france) |> 
  select(school_name,   id_geofla) |> 
  st_drop_geometry() |> 
  mutate(med_schools_ind = 1)




join_klarsfeld = klarsfeld_raw |> 
  left_join(joined_med_schools, join_by(id_geofla)) |> 
  mutate(med_schools_ind = ifelse(is.na(med_schools_ind), 0, med_schools_ind))




write_csv(join_klarsfeld, here::here("processed_dat", "klarsfeld_meds_camps_election.csv"))

return(join_klarsfeld)

}
