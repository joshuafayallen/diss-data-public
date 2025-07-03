
merge_klarsfeld_cage = \(data, selecting_vars = c("palpha1901",
                            "palpha1902","palpha1903","palpha1904","palpha1905","palpha1906",
                            "palpha1907","palpha1908","palpha1909","palpha1910","palpha1911",
                            "palpha1912","palpha1913","palpha1914","palpha1915","palpha1916",
                            "palpha1917","palpha1918","palpha1919","palpha1920","palpha1921",
                            "palpha1922","palpha1923","palpha1924","palpha1925","palpha1926",
                            "palpha1927","palpha1928","palpha1929","palpha1930","palpha1931",
                            "palpha1932","palpha1933","palpha1934","palpha1935","palpha1936",
                            "palpha1937","palpha1938","palpha1939", "perrev1919","perrev1920","perrev1921","perrev1922",
                            "perrev1923","perrev1924","perrev1925","perrev1926","perrev1927",
                            "perrev1928","perrev1929","perrev1930","perrev1931",
                            "perrev1932","perrev1933","perrev1934","perrev1935",
                            "perrev1936","perrev1937","perrev1938","perrev1939","recette1911","recette1920",
                            "etranger1919","etranger1920",
                            "etranger1921","etranger1922","etranger1923","etranger1924",
                            "etranger1925","etranger1926","etranger1927","etranger1928",
                            "etranger1929","etranger1930","etranger1931","etranger1932",
                            "etranger1933","etranger1934","etranger1935","etranger1936","etranger1937","etranger1938","etranger1939"), election_vars =
      c('pvoix_tixiervignancour_1965', 'pvoix_lepen_1974', 'pvoix_lepen_1988', 'pvoix_lepen_1995',
        'pvoix_lepen_2002', 'pvoix_lepen_2007', 'pvoix_lepen_2007',
        'pvoix_mlepen_2012', 'pvoix_mlepen_2017') ){

ids_misc = c(7542,  53402, 67335,  9895, 11617, 13879, 12275, 68910, 12367, 60732, 13644, 15893,
              17146, 20232, 27108, 27109, 27110, 27518, 45963, 64115, 64116, 64117, 64118,
              19050, 19162, 20085, 20086, 20087,20197, 22709, 23112, 23113,23114,
              23998, 24844, 56552, 56553, 56554, 56555, 25066, 25096, 26708, 30498,
              31112, 32083, 41684, 33480, 36511, 37684, 69882, 73596, 41691, 43081, # nolint
              43539, 45318, 48370, 48371, 48372, 50503, 50557, 50848, 51693, 57498,
              57499, 61695, 61696, 61697, 73577, 63809, 63944, 63945, 66746, 66788,
              69291, 69292, 69293, 67053, 69982, 69983, 69984, 69985, 72050, 72997)

last_camp_address = c("40 Chem. de la Badesse, 13290 Aix-en-Provence, France",
                      "36 Rue Barra, 49045 Angers, France", 
                      "15 Av. François Laguerre, 09400 Tarascon-sur-Ariège, France",
                      " 5 Rue des Déportés, 45340 Beaune-la-Rolande, France",
                      "Rue Jean Macé, 33130 Bègles, France",
                      "All. du Grand Chêne, 31120 Portet-sur-Garonne, France",
                      "47440 Casseneuil, France",
                      "47110 Allez-et-Cazeneuve, France",
                      "2 bis Av. des Martyrs de la Liberté, 60200 Compiègne, France",
                      "110-112 Av. Jean Jaurès, 93700 Drancy, France",
                      "Imp. d'Ossau, 64190 Gurs, France",
                      "1 Imp. Bruno Frei, 09700 Le Vernet, France",
                      "Rue du château d’eau, 3140 Noé",
                      "Avenue Christian Bourquin 66600,
Salses Le Chateau")


klarsfeld_geocoded = data |> 
  mutate(foreign_born = ifelse(str_detect(place_of_birth, "France",
                                          negate = TRUE), 1, 0),
         treat_ind = 1,
         has_camp_ind = ifelse(fix_add %in% last_camp_address | !is.na(insee_numb),
                               1, 0),
          has_camp_ind = ifelse(has_camp_ind == 1 | is.na(comm_name_hand), 1, 0)) |> 
  filter(!jid %in% ids_misc) 


klarsfeld_sf = klarsfeld_geocoded |> 
  st_as_sf(coords = c("long", "lat"), crs = st_crs("EPSG:4326"))

communes_cage = read_sf(here::here(
                           "shp-files",
                           "communes.geojson"))|> 
  janitor::clean_names() |> 
  filter(nom_reg != "CORSE")





transformed_klarsfeld_sf = klarsfeld_sf |> 
  st_transform(st_crs(communes_cage))


 
 joined_klarsfeld = transformed_klarsfeld_sf |> 
  st_join(communes_cage) 
 
 
cage_et_al_analysis = haven::read_dta(here::here("data", 
                                                 "analysis_dataset.dta"))
  
  
# bring_in_demographics = 


 
 ## lets start by just getting rid of columns that are very clearly not going to be useful

joined_analysis = joined_klarsfeld |> 
  select(fix_add:statut, convoy_list) |> 
  left_join(cage_et_al_analysis, join_by(id_geofla)) 





create_exposure = joined_analysis |>
  mutate(last_camp_ind = ifelse(!(is.na(comm_name_hand)|is.na(insee_numb)) | fix_add %in% last_camp_address,
                                TRUE, FALSE),
         died_in_french_camp = ifelse(convoy_list == "90", 1, 0),
         belgian_convoys = str_extract_all(convoy_list, "\\b(?:[IVXLCDM]+)\\b"),
         deported_belgium_administred_territory = ifelse(convoy_list %in% belgian_convoys,
                                                         1, 0),
         summarily_executed = ifelse(convoy_list == "91", 1, 0),
         suicide = ifelse(convoy_list == "92", 1, 0),
         deported_as_political_opponents = ifelse(convoy_list == "83", 1, 0),
         green_ticket_ind = ifelse(convoy_list == "2", 1, 0),
         date_of_arrest = ifelse(green_ticket_ind == 1, "May 14, 1941", NA)) |> 
  select(-belgian_convoys) |> 
  mutate(total_without_camp = ifelse(last_camp_ind == FALSE, n(), NA),
         total_with_camp = n(),
         exposure_sans_camp = (total_without_camp/pop1936) * 100,
         exposure_with_camp = (total_with_camp/pop1936) * 100, 
         .by = c(id_geofla))



## so we have the exposure measure
## now lets get that into the shapefile 
## 
agg_exposure_clean = create_exposure |> 
  relocate(c(treat_ind, id_geofla), .before = pop2015) |> 
  group_by(id_geofla) |> 
  summarise(exposure_sans_camp = mean(exposure_sans_camp),
            exposure_with_camp = mean(exposure_with_camp),
            treat_ind = mean(treat_ind)) |> 
  st_drop_geometry()

agg_exposurejoined = cage_et_al_analysis |> 
  left_join(agg_exposure_clean) |> 
  select(-c(mover, nonmover, ParaCol:Female, feb:dec, join_count, pop1937:longitudesq),
         -starts_with("iden"), -starts_with("N_"),
         -starts_with("deads_Verdun"), -starts_with('placebo'), -contains("merge")) |>
         mutate(nom_reg = iconv(nom_reg, from = 'latin1', to = 'UTF-8'))
  

  
dem_data = read_csv('processed_dat/election_dem_data.csv') |>
  select(all_of(selecting_vars), all_of(election_vars), codecommune)
  
  
agg_exposure_joined = agg_exposurejoined |>
  left_join(dem_data, join_by(insee_com == codecommune))
  



return(agg_exposure_joined)



}
