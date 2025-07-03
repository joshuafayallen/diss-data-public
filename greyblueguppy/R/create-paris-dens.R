library(tidyverse)
library(sf)
library(spatstat)

source(here::here("R", "misc-locals.R"))


communes = st_read(here::here("processed_dat",
                           "communes.csv"),
                options = "GEOM_POSSIBLE_NAMES=wkt") |> 
  select(-wkt) |> 
  filter(nom_reg != "CORSE") |>
  st_set_crs("EPSG:2154")



ggplot(communes) +
  geom_sf() +
  coord_sf(datum = NA) +
  theme_void() +
  theme(panel.background = element_rect(fill = "white"))


klarsfeld_geocoded = read_csv(here::here("shp-files", "geocoded_last_addresses-redo.csv")) |>
  mutate(foreign_born = ifelse(str_detect(place_of_birth, "France",
                                          negate = TRUE), 1, 0),
         treat_ind = 1,
         has_camp_ind = ifelse(fix_add %in% last_camp_address | !is.na(insee_numb) | !is.na(comm_name_hand),
                               1, 0)) |> 
  filter(!jid %in% ids_misc)



klarsfeld_sf = klarsfeld_geocoded|>
st_as_sf(coords = c("long", "lat"), crs = st_crs("EPSG:4326")) 

klarsfeld_sf_tr = klarsfeld_sf |>
st_transform(crs = st_crs(communes))





just_paris = klarsfeld_sf_tr|>
st_join(communes) |>
filter(str_detect(nom_com, "PARIS") & str_detect(nom_com, "ARROND"))

paris = communes |>
filter(str_detect(nom_com, "PARIS") & str_detect(nom_com, "ARROND"))


table(just_paris$nom_com)

glimpse(just_paris)


klarsfeld_pp = as.ppp(just_paris$geometry, W = as.owin(paris))

paris_dens = stars::st_as_stars(density(klarsfeld_pp, dimyx = 300))

head(communes)

paris_dens_sf = st_as_sf(paris_dens) |>
st_set_crs("EPSG:2154") 


ggplot() +
geom_sf(data = paris_dens_sf, aes(fill = v)) +
geom_sf(data = paris, fill = NA) 