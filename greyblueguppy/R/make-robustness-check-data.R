merge_robust_data = \(spatial_data,
                     control_data,
                     communes_data,
                     controls =c("med_schools_ind",
                                "logww1",
                                "verdun_petain",
                                "palpha1935",
                                "perrev1935",
                                "etranger1935" )){

control_dat = control_data 

communes_france = communes_data


  ids_misc = c(7542,  53402, 67335,  9895, 11617, 13879, 12275, 68910, 12367, 60732, 13644, 15893,
               17146, 20232, 27108, 27109, 27110, 27518, 45963, 64115, 64116, 64117, 64118,
               19050, 19162, 20085, 20086, 20087,20197, 22709, 23112, 23113,23114,
               23998, 24844, 56552, 56553, 56554, 56555, 25066, 25096, 26708, 30498,
               31112, 32083, 41684, 33480, 36511, 37684, 69882, 73596, 41691, 43081, # nolint
               43539, 45318, 48370, 48371, 48372, 50503, 50557, 50848, 51693, 57498,
               57499, 61695, 61696, 61697, 73577, 63809, 63944, 63945, 66746, 66788,
               69291, 69292, 69293, 67053, 69982, 69983, 69984, 69985, 72050, 72997)
  

 klarsfeld_sf = spatial_data  |>
    st_as_sf(coords = c("long", "lat"), crs = st_crs("EPSG:4326"))
  

 polling_stations = read_sf('polling-station-shape-file/bvcom07.geojson') |>
  select(bvcom = BVCOM, nom = com07_name)



### these are just raw election results 
election_results = readxl::read_xls('polling-station-shape-file/data07.xls') |>
  janitor::clean_names() |>
  rename(lepen_votes = lep07t1,
         votes_cast = vot07t1) |>
  select(lepen_votes, votes_cast, bvcom)

joined_elections = polling_stations |> 
  left_join(election_results, join_by(bvcom)) |> 
  mutate(lepen_share_2007 = (lepen_votes/votes_cast) *100) |> 
  select(bvcom, nom, lepen_share_2007, lepen_votes) |> 
  janitor::clean_names()



klarsfeld_sf = klarsfeld_sf |>
  st_transform(st_crs(joined_elections))



miles_to_km <- function(miles) {
  km <- miles * 1.60934
  return(km)
}


out = miles_to_km(miles = 2)  # 3 miles is alot in a city

kms = out * 1000


buffed = st_buffer(polling_stations, dist = kms)

add_treated = st_intersection(x = klarsfeld_sf, y = buffed)

add_treat_ind = joined_elections |>
  mutate(treated = bvcom %in% add_treated$bvcom)

add_demo_variables = communes_france |>
  janitor::clean_names() |>
  left_join(control_dat, join_by(id_geofla)) |>
  janitor::clean_names() |> 
  select(id_geofla:nom_reg_x, all_of(controls))
  
add_controls = add_treat_ind |>
  st_join(add_demo_variables)

make_centroids = add_controls |>
  st_centroid()  
  
spat_data = make_centroids |>
  mutate(X = st_coordinates(make_centroids)[,1],
         Y = st_coordinates(make_centroids)[,2],
         treated = ifelse(treated == TRUE, 1, 0)) |>
  st_drop_geometry() |> 
  drop_na(lepen_share_2007) |> 
  ## subset it to only include the region around paris
  filter(nom_reg_x == 'ILE-DE-FRANCE') |> 
  select(-ends_with('_x')) 
  
  return(spat_data)
}