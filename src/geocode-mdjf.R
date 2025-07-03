# this is the geocoding script 
# this took a bit of interaction since some the addressses were a little bit wonky 
# I apologize for how weird this one is 


pacman::p_load("tidygeocoder", 'ggiraph' ,"arrow", "sf", "tidyverse")

raw_dat = read_parquet(here::here("data", "memorial-full.parquet")) |> 
  mutate(jid = row_number())


hand_code_camps = read_csv(here::here("data", "handcoded-internment-camps.csv"),
                           col_types = cols(insee_numb = col_character())) 


hand_code_ids = hand_code_camps |> 
  select(jid) |> 
  deframe()


## First thing is to fix the addresses for the camps 
## some of it worked but some of it didn't so just including the
## the hand code camps script here 


ids = c(13623, 15101, 15103, 15104, 15107, 15108, 15109, 15110, 15111, 15112,
        15113, 15114, 15115, 15119, 15120, 15121, 15122, 15124, 15125, 15126,
        15127, 15128, 15130, 37206, 37207)

raw_dat = raw_dat |> 
mutate(internment_transit_camp = case_when(address == "Camp d'internement - Noé, Haute-Garonne" ~ "Noe",
                                           address == "Camp d'internement - Séreilhac, Haute-Vienne" ~ "Séreilhac",
                                           address == "Camp d'internement - Nexon, Haute-Vienne" ~ "Nexon",
                                           address == "Camp d'internement - La Meyze, Haute-Vienne" ~ "La Meyze",
                                           address == "Camp d'internement, Gurs, Pyrénées-Atlantiques" ~ "Gurs",
                                           address == "Camp d'internement, Le Vernet, Ariège" ~ "Le Vernet",
                                           address == "Camp d'internement des Milles, Aix-en-Provence, Bouches-du-Rhône" ~ "Camp des Milles, Aix-en-Provence",
                                           address == "Camp d'internement - Pithiviers, Loiret" ~ "Pithiviers", 
                                           str_detect(address, "Camp d'internement de Récébédou - 2") ~ "Récébédou",
                                           jid == 12910 ~ "Monts",
                                           jid == 21180 ~ "Poitiers",
                                           internment_transit_camp == "Lons-le-Saunier" ~ "Gurs",
                                           jid == 4399 ~ "Camp des Milles, Aix-en-Provence",
                                           jid %in% c(5271, 5944) ~ "Rivesaltes",
                                           jid == 70359 ~ "Sisteron",
                                           internment_transit_camp == "Monts" ~ "Camp de La Lande, Monts", 
                                           jid %in% c(6948, 7141) ~ "Le Vernet",
                                           jid == 2386 ~ "Gurs",
                                           jid == 5810 ~ "Rivesaltes",
                                           jid == 16185 ~ "Septfonds",
                                           internment_transit_camp == "Perpignan" ~ "Rivesaltes",
                                           internment_transit_camp == "Vénissieux" ~ "Gurs",
                                           jid %in% ids[2:23] ~ "Brens", 
                                           jid %in% c(52122, 52121, 12951) ~ "Lamotte-Beuvron",
                                           jid == ids[1] ~ "Allez-et-Cazeneuve",
                                           jid %in% ids[24:25] ~ "Saint Sulpice",
                                           internment_transit_camp == "Tarn-et-Garonne" ~ "Septfonds",
                                           internment_transit_camp == "Yonne" ~ "Saint-Denis-lès-Sens",
                                           internment_transit_camp == "Écrouves" ~ "Vittel",
                                           jid == 1313 ~ "Gurs",
                                           .default = internment_transit_camp))



add_camp_adds = raw_dat |> 
  mutate(fix_add = ifelse(jid %in% hand_code_ids, hand_code_camps$address, address),
         internment_transit_camp = ifelse(jid %in% hand_code_ids,
                                         hand_code_camps$internment_transit_camp,
                                         internment_transit_camp)) |> 
  mutate(fix_add = case_when(str_detect(internment_transit_camp, "Camp des Milles") ~ "40 Chem. de la Badesse, 13290 Aix-en-Provence, France",
                             internment_transit_camp == "Angers" ~ "36 Rue Barra, 49045 Angers, France", 
                             internment_transit_camp == "Ariège" ~ "15 Av. François Laguerre, 09400 Tarascon-sur-Ariège, France",
                             internment_transit_camp == "Beaune-la-Rolande" ~ " 5 Rue des Déportés, 45340 Beaune-la-Rolande, France",
                             internment_transit_camp == "Bordeaux" ~ "Rue Jean Macé, 33130 Bègles, France",
                             str_detect(internment_transit_camp, "Récébédou") ~ "All. du Grand Chêne, 31120 Portet-sur-Garonne, France",
                             internment_transit_camp == "Casseneuil" ~ "47440 Casseneuil, France",
                             internment_transit_camp == "Château de Tombebouc, Allez-et-Cazeneuve" ~ "47110 Allez-et-Cazeneuve, France",
                             internment_transit_camp == "Compiègne" ~ "2 bis Av. des Martyrs de la Liberté, 60200 Compiègne, France",
                             internment_transit_camp == "Drancy" ~ "110-112 Av. Jean Jaurès, 93700 Drancy, France",
                             internment_transit_camp == "Gurs" ~ "Imp. d'Ossau, 64190 Gurs, France",
                             internment_transit_camp == "Le Vernet" ~ "1 Imp. Bruno Frei, 09700 Le Vernet, France",
                             internment_transit_camp == "Noe" ~ "Rue du château d’eau, 3140 Noé",
                             internment_transit_camp == "Rivesaltes" ~ "Avenue Christian Bourquin 66600,
Salses Le Chateau",
internment_transit_camp == "Septfonds"  ~ "Lalande, 82240 Septfonds, France",
internment_transit_camp == "Sisteron" ~ "Mnt de la Citadelle, 04200 Sisteron, France",
internment_transit_camp == "Pithiviers" ~ "2 Rue de Pontournois, 45300 Pithiviers-le-Vieil, France",
internment_transit_camp == "Vittel" ~ "80 Av. Bouloumie, 88800 Vittel, France",
.default = fix_add),
,
comm_name_hand = case_when(internment_transit_camp == "Bram" ~ "Montreal",
                           internment_transit_camp ==  "Brens" ~ "Gaillac"  ,
                           internment_transit_camp == "Camp de La Lande, Monts" ~ "Monts",
                           internment_transit_camp == "Monts" ~ "Monts",
                           jid %in% c(52122,52121, 12951) ~ "Lamotte-Beuvron",
                           internment_transit_camp == "Casseneuil" ~ "Casseneuil",
                           internment_transit_camp == " Château de Tombebouc, Allez-et-Cazeneuve" ~ "Allez-et-Cazeneuve",
                           internment_transit_camp == "Saint-Denis-lès-Sens" ~ "Saint-Denis-lès-Sens",
                           internment_transit_camp == "La Meyze" ~ "La Meyze",
                           internment_transit_camp == "Nexon" ~ "Nexon",
                           internment_transit_camp == "Poitiers" ~ "Poitiers",
                           internment_transit_camp == "Saint Sulpice"  ~ "Saint-Sulpice-la-Pointe",
                           internment_transit_camp == "Séreilhac" ~ "Séreilhac",
                           internment_transit_camp  == "Aude" ~ "Sallèles-d'Aude"),
insee_numb = case_when(comm_name_hand == "Monts" ~ "37260",
                       internment_transit_camp == "Bram" ~ "11290",
                       internment_transit_camp == "Brens" ~ "8160",
                       comm_name_hand == "Casseneuil" ~ "47440",
                       comm_name_hand == "Allez-et-Cazeneuve" ~ "47110",
                       comm_name_hand == "La Meyze" ~ "87800",
                       comm_name_hand == "Poitiers" ~ "86194",
                       comm_name_hand == "Saint-Sulpice-la-Pointe" ~ "8127",
                       comm_name_hand == "Séreilhac" ~ "87620",
                       comm_name_hand == "Lamotte-Beuvron" ~ "41106",
                       comm_name_hand == "Sallèles-d'Aude" ~ "11369",
                       comm_name_hand == "Saint-Denis-lès-Sens" ~ "89342",
                       comm_name_hand == "Nexon" ~ "87106"),
demarc_ind = ifelse(str_detect(address, "Ligne de démarcation"), TRUE, FALSE))

limit_addresses = add_camp_adds |> 
  filter(is.na(insee_numb), !is.na(fix_add)) |> 
  mutate(fix_add = str_replace_all(fix_add, "\\b\\w+\\s*-\\s*", ""),
         commas = str_count(fix_add, ","),
         fix_add = str_replace_all(fix_add,"Logis n°", "Boulevard du Docteur Charles Barnier, Toulon, Var" )) |>
  filter(commas != 1, demarc_ind != TRUE)

geocoded_addresses = limit_addresses |> 
  geocode_combine(queries = list(
    list(method = "osm"),
    list(method = "geoapify"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add"))

write_csv(geocoded_addresses, here::here("data", "last-address-geocoded.csv"))


geocoded_raw = read_csv(here::here("data", "last-address-geocoded.csv"))

geocode_sf = geocoded_raw |> 
  st_as_sf(coords = c("long", "lat"), crs = st_crs("EPSG:4326"))


french_communes = read_sf(here::here("data", "communes.geojson"))

french_dept = read_sf(here::here("data", "departements.geojson"))

# this is the basics of where I got random points that needed to be fixed by hand
# i ommit the rest of the instances just for brevity 
 # french_map_inter =  ggplot() +
 #  geom_sf_interactive(data = french_dept) +
 #  geom_sf_interactive(data = prune_map, aes(tooltip = surname))  


 # 
 # 
 # inter = girafe(code,
 #               ggobj = french_map_inter)


names_to_fix = c("WINDLAND", "IKKA", "HACKMAN", "MUTTERER", "FRIDKIN",
                 "WAHRENBERG", "FLEISCH", "RESNIKOFF", "DREYFUS-ROSE",
                 "PREIGHER", "MOUTAL", "SLONKA", "NAHM", "LEVINE", "GAERTNER",
                 "RHEIMS", "SLOTOWSKI", "ISRAEL", "MARCUS", "EMMANUEL", "DAVIDSON",
                 "KUPERMAN")
  
fix_coords = geocoded_raw |> 
  filter(surname %in% names_to_fix) |> 
  select(-lat, -long, -query) |> 
  mutate(fix_add = str_remove_all(fix_add, "France"),
        fix_add = paste0(address, ",", " ", "France")) 


geocode_fix_coords = fix_coords |> 
  geocode_combine(queries = list(
    list(method = "osm"),
    list(method = "geoapify"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add"))

fix_id = geocode_fix_coords |> 
  select(jid) |> 
  deframe()


geocode_fix_coords = geocode_fix_coords |> 
  select(jid, lat, long)



adding_fix_coords = geocoded_raw |> 
left_join(geocode_fix_coords, join_by(jid)) |> 
  mutate(lat = ifelse(jid %in% fix_id, lat.y, lat.x),
         long = ifelse(jid %in% fix_id, long.y, long.x))

check = adding_fix_coords |> 
  filter(long < -15 |long > 15 | lat < -15 )

geocode_check = check |>
  select(-lat, -long, -contains("query")) |> 
  mutate(fix_add = str_remove_all(address, "France"),
         fix_add = paste0(address, ",", " ", "France")) |> 
  geocode_combine(queries = list(
    list(method = "osm"),
    list(method = "geoapify"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add"))

clean_up_check = geocode_check |> 
  select(jid, lat, long)


ids_from_check = clean_up_check |> 
  select(jid) |> 
  deframe()

add_remaining_ids = adding_fix_coords |> 
  select(-ends_with("y"), -ends_with("x")) |> 
  left_join(clean_up_check, join_by(jid)) |> 
  mutate(lat = ifelse(jid %in% ids_from_check, lat.y, lat.x),
         long = ifelse(jid %in% ids_from_check, long.y, long.x)) 

surnames_to_check = c("Vernick", "Daie", "Hackmann", "Jacob", "Jezierski",
                      "Seni", "Hornick", "Steiner", "Lazarus", "Cuckierman",
                      "Benoussan", "Zyserman", "Faust")


surnames_to_check = str_to_upper(surnames_to_check)

fix_remaining_last_names = add_remaining_ids |> 
  filter(surname %in% surnames_to_check) 

remaining_last_names = fix_remaining_last_names |> 
  select(-lat, -long) |> 
  mutate(fix_add = str_remove_all(fix_add, "France"),
         fix_add = paste0(address, ",", " ", "France"),
         fix_add = case_when(fix_add == "Camp d'internement - Camp d'internement, Compiègne, Oise, France" ~ "2 bis Av. des Martyrs de la Liberté, 60200 Compiègne, France",
                            fix_add == "Camp d'internement - Cité de la Muette, Drancy, Seine-Saint-Denis, France" ~ "110-112 Av. Jean Jaurès, 93700 Drancy, France",
                            fix_add == "Camp d'internement de Récébédou - 2, Allée du Grand Chêne, Portet-sur-Garonne, Haute-Garonne, France" ~ "All. du Grand Chêne, 31120 Portet-sur-Garonne, France",
                            fix_add == "Camp d'internement des Milles, Aix-en-Provence, Bouches-du-Rhône, France" ~ "40 Chem. de la Badesse, 13290 Aix-en-Provence, France",
                            fix_add == "Camp d'internement, Gurs, Pyrénées-Atlantiques, France" ~ "Imp. d'Ossau, 64190 Gurs, France",
                            internment_transit_camp == "Camp d'internement, Le Vernet, Ariège, France" ~ "1 Imp. Bruno Frei, 09700 Le Vernet, France",
                            .default = fix_add))



geocode_remaining_last_names = remaining_last_names |> 
  geocode_combine(queries = list(
    list(method = "osm"),
    list(method = "google"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add")) 

ids_from_names = geocode_remaining_last_names |> 
  select(jid) |> 
  deframe()


clean_remaining_last = geocode_remaining_last_names |> 
  select(jid, lat, long) 

add_remaining_last_names = add_remaining_ids |> 
  select(-ends_with("y"), -ends_with("x")) |>
  left_join(clean_remaining_last, join_by(jid)) |>
  mutate(lat = ifelse(jid %in% ids_from_names, lat.y, lat.x),
         long = ifelse(jid %in% ids_from_names, long.y, long.x)) 

get_last_name = add_remaining_last_names |> 
  filter(surname == "JEZIERNICKI")


get_points = add_remaining_last_names |> 
  filter(lat >51| long > 10)

geocode_get_points = get_points |> 
  select(-lat, -long) |> 
  mutate(fix_add = str_remove_all(fix_add, "France"),
         fix_add = paste0(address, ",", " ", "France")) |> 
  geocode_combine(queries = list(
    list(method = "google"),
    list(method = "osm"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add")) 

clean_check_points = geocode_get_points |> 
  select(jid, lat, long)


add_check_points = add_remaining_last_names  |> 
  select(-ends_with("y"), -ends_with("x")) |>
  left_join(clean_check_points, join_by(jid)) |>
  mutate(lat = ifelse(jid %in% jid_check_points, lat.y, lat.x),
         long = ifelse(jid %in% jid_check_points, long.y, long.x))


what_is_going_on = add_check_points |> 
  filter(lat < 10) |> 
  select(-lat, -long, -ends_with(".x"), -ends_with(".y")) |> 
  mutate(fix_add = str_remove_all(fix_add, "France"),
         fix_add = paste0(address, ",", " ", "France")) |> 
  geocode_combine(queries = list(
    list(method = "google"),
    list(method = "osm"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add")) 

clean_what_is_going_on = what_is_going_on |> 
  select(jid, lat, long)


jid_what_is_going_on = what_is_going_on |> 
  select(jid) |> 
  deframe()


add_what_is_going_on = add_check_points |>
  select(-ends_with("y"), -ends_with("x")) |>
  left_join(clean_what_is_going_on, join_by(jid)) |> 
  mutate(lat = ifelse(jid %in% jid_what_is_going_on, lat.y, lat.x),
         long = ifelse(jid %in% jid_what_is_going_on, long.y, long.x))

last_names = c("Mandel", "Menasce", "Samuel", "Scherman", "Hochsztajn",
               "Gerschel", "Feuerlicht", "Bronstein", "Pfeffer", "Medzioukes",
               "Berger", "Cohen")

last_names = str_to_upper(last_names)


remaining_last_names = add_what_is_going_on |> 
  filter(surname %in% last_names)

geocode_remaining_last_names = remaining_last_names  |> 
  select(-lat, -long, -ends_with(".x"), -ends_with(".y")) |> 
  mutate(fix_add = str_remove_all(fix_add, "France"),
         fix_add = paste0(fix_add, ",", " ", "France")) |> 
  geocode_combine(queries = list(
    list(method = "google"),
    list(method = "osm"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add"))


jid_clean_remaining_last_namers = clean_remaining_last_namers |>
  select(jid) |>
  deframe()


hopefully_last_time = add_what_is_going_on |>
  select(-ends_with("y"), -ends_with("x")) |>
  left_join(clean_remaining_last_namers, join_by(jid)) |>
  mutate(lat = ifelse(jid %in% jid_clean_remaining_last_namers, lat.y, lat.x),
         long = ifelse(jid %in% jid_clean_remaining_last_namers, long.y, long.x))


check_hopefully_last_time = hopefully_last_time |>
  st_as_sf(coords = c("long", "lat"), crs = st_crs("EPSG:4326"))

last_names = c("Bolz", "Brenmann", "Mendels", "Menasce") |> 
  str_to_upper()

get_last_names_to_check = hopefully_last_time |> 
  filter(surname %in% last_names) |> 
  mutate(fix_add = str_remove_all(fix_add, "France|Hôtel de la"),
         fix_add = paste(fix_add,   "France")) 


geocode_last_names_to_check = get_last_names_to_check |>
  select(-lat, -long, -ends_with(".x"), -ends_with(".y")) |>
  geocode_combine(queries = list(
    list(method = "osm"),
    list(method = "google"),
    list(method = "mapbox"),
    list(method = "here")), global_params = list(address = "fix_add"))


get_ids = geocode_last_names_to_check |> 
  select(jid) |> 
  deframe()


clean_the_last_names = geocode_last_names_to_check |> 
  filter(jid %in% get_ids) |> 
  select(jid, lat, long)


joining_the_rest = hopefully_last_time |> 
  select(-ends_with("y"), -ends_with("x")) |>
  left_join(clean_the_last_names, join_by(jid)) |>
  mutate(lat = ifelse(jid %in% get_ids, lat.y, lat.x),
         long = ifelse(jid %in% get_ids, long.y, long.x))


arrow::write_parquet(joining_the_rest, here::here("data", "klarsfeld-geocoded.parquet"))