library(targets)
library(tarchetypes)
library(crew)



suppressPackageStartupMessages(library(dplyr))




options(tidyverse.quite = TRUE,
        dplyr.summarise.inform = FALSE)




tar_option_set(packages = c("arrow",
                            "tidyverse", "sf", "WeightIt", "MetBrewer"))

vichy_depts = c("Basses-Pyrenees", "Hautes-Pyrenees", "Ariege", "Pyrenees-Orientales", "Herault", "Gard", "Bouches-Du-Rhone", "Var", "Alpes-Maritimes", "Basses-Alpes", "Savoie", "Hautes-Alpes", "Haute-Savoie", "Ain", "Jura", "Saone-Et-Loire", "Rhone", "Loire", "Allier", "Indre", "Haute-Vienne", "Dordogne", "Lot-Et-Garonne", "Gers", "Lot", "Tarn-Et-Garonne", "Haute-Garonne", "Aude", "Tarn", "Aveyron", "Lozere", "Ardeche", "Drome", "Isere", "Correze", "Creuse", "Aude", "Cantal", "Puy-de-Dome", "Vaucluse", "Puy-De-Dome", "Corse", "Herault", "Haute-Loire", "Haute-Venne" )

forbidden_zone = c("Ardennes", "Somme", "Aisne", "Vosges", "Doubs", "Territoire-De-Belfort",
                   "Haute-Marne", "Marne", "Meurthe-Et-Moselle", "Oise", "Somme",
                   "Meuse", "Haute-Saone")

ids_misc = c(7542, 53402, 67335, 9895, 11617, 13879, 12275, 68910, 12367, 60732,
             13644, 15893,  17146, 20232, 27108, 27109, 27110, 27518, 45963, 64115,
             64116, 64117, 64118, 19050, 19162, 20085, 20086, 20087,20197, 22709,
             23112, 23113, 23114, 23998, 24844, 56552, 56553, 56554, 56555, 25066,
             25096, 26708, 30498,  31112, 32083, 41684, 33480, 36511, 37684,
             69882, 73596, 41691, 43081,  43539, 45318, 48370, 48371, 48372,
             50503, 50557, 50848, 51693, 57498, 57499, 61695, 61696, 61697,
             73577, 63809, 63944, 63945, 66746, 66788,  69291, 69292, 69293, 
             67053, 69982, 69983, 69984, 69985, 72050, 72997)

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
                      "Avenue Christian Bourquin 66600, Salses Le Chateau")


overseas = c("GUADELOUPE","GUYANE","MARTINIQUE","MAYOTTE","LA REUNION",
             "CORSE", "NOUVELLE-CALEDONIE", "POLYNESIE-FRANCAISE",
             "WALLIS-ET-FUTUNA", "SAINT-MARTIN/SAINT-BARTHELEMY",
             "SAINT-PIERRE-ET-MIQUELON", "HAUTE-CORSE",
             "CORSE-DU-SUD")


annexed = c("Moselle", "Bas-Rhin", "Haut-Rhin")

command_bel = c("Pas-De-Calais", "Nord")


elections_ctrols = c("sh_nuance_extreme_gauche_32", "sh_nuance_extreme_gauche_36", 
                     "sh_nuance_extreme_droite_32", "sh_nuance_extreme_droite_36",
                     "sh_nuance_droite_32", "sh_nuance_droite_36",
                     "sh_nuance_centre_gauche_32", "sh_nuance_centre_gauche_36",
                     "sh_nuance_centre_droit_32", "sh_nuance_centre_droit_36",
                     "sh_nuance_gauche_32", "sh_nuance_gauche_36")

# nolint
elect_religious = c(elections_ctrols, "share_refractory",
                    "med_schools_ind", "wheat_suit")

relg_verdun_elect_share = c("logww1", "verdun_petain", elect_religious)      



here_rel <- function(...) {fs::path_rel(here::here(...))}


helpers = list.files(path = 'helpers',
                     pattern = ".R$", full.names = TRUE)


purrr::map(helpers, source)

r_stuff = list.files(path = 'R', 
                     pattern = ".R$", full.names = TRUE)


purrr::map(r_stuff, possibly(source))

source('R/misc-locals.R')

## hard set these 


# Set target-specific options such as packages:
# tar_option_set(packages = "utils") # nolint

# End this file with a list of target objects.
list(
  tar_target(raw_data,
             here_rel('data', 'klarsfeld_geocoded.parquet'),
             format = 'file'),
  tar_target(readin,
             arrow::read_parquet(raw_data)),
  tar_target(communes_shape_file,
            here_rel('shp-files', 'communes.geojson'),
            format = 'file'),
  tar_target(commune_shp,
             sf::read_sf(communes_shape_file)),
  tar_target(mergeklarsfeldcage,
             merge_klarsfeld_cage(data = readin)),
  tar_target(mergecamps,
             merge_camps(klarsdat = mergeklarsfeldcage)),
  tar_target(mergemedschools,
             merging_med_schools(klarsdat = mergecamps)),
  tar_target(mergereligion,
             merging_religion(klarsdat = mergemedschools)),
  tar_target(fix_elections,
             clean_past_elections(relg_data =  mergereligion)), 
  tar_target(panelklars,
             create_panel(data_longer = fix_elections)),
  tar_target(make_weights_deport,
             make_weights(data_obj = fix_elections, treat = treat_ind, it = 6000, spatial_var = id_geofla)),
  tar_target(make_weights_camp,
             make_weights(data_obj = fix_elections, treat = has_camp, it = 50000, spatial_var = id_geofla)),
  tar_target(sensitivity_analysis_deport,
             bart_sens(bart_dat = fix_elections,
                       treatment = treat_ind,
                       dv = pvoix_lepen_2002)),
  tar_target(sensitivity_analysis_camp,
             bart_sens(bart_dat = fix_elections,
                       treatment = has_camp,
                       dv = pvoix_lepen_2002)),
  tar_target(sensitivity_analysis_tv_deport,
             bart_sens(bart_dat = fix_elections,
                      treatment = treat_ind,
                      dv = pvoix_tixiervignancour_1965)),
  tar_target(sensitivity_analysis_tv_camp,
             bart_sens(bart_dat = fix_elections,
                       treatment = has_camp,
                       dv = pvoix_tixiervignancour_1965)),
  tar_target(imputed_weights_camp,
             make_imputed_weights(data = mergereligion, treat_name = has_camp,
                                 it = 50000, spatial_var = id_geofla)),
  tar_target(imputed_sens_lepen_camp,
             bart_sens_imp(weight_obj = imputed_weights_camp,
                           treatment = has_camp,
                           dv = pvoix_lepen_2002)),
  tar_target(imputed_sens_tv,
             bart_sens_imp(weight_obj = imputed_weights_camp,
                           treatment = has_camp,
                           dv = pvoix_tixiervignancour_1965)),
  tar_target(imputed_weights_deport,
             make_imputed_weights(data = mergereligion, treat_name = treat_ind, over = TRUE,
                                  spatial_var = id_geofla)),
  tar_target(imputed_sens_lepen_deport,
             bart_sens_imp(weight_obj = imputed_weights_deport,
                           treatment = treat_ind, 
                           dv = pvoix_lepen_2002)),
  tar_target(imputed_sens_tv_deport,
             bart_sens_imp(weight_obj = imputed_weights_deport,
                           treatment = treat_ind,
                           dv = pvoix_tixiervignancour_1965)),
  tar_target(cf_deport,
             forest_estimation(data = fix_elections, dv = pvoix_lepen_2002, treat = treat_ind)),
  tar_target(cf_camp,
             forest_estimation(data = fix_elections, dv = pvoix_lepen_2002, treat = has_camp)),
  tar_target(conley_smith_data,
             merge_robust_data(spatial_data = readin, communes_data = commune_shp ,control_data = mergereligion)),
  tar_target(conley_form, 
        est_forms(data = conley_smith_data, dv = lepen_share_2007, iv = treated)),
 tar_target(opt_basis_check,
            spatInfer::optimal_basis(fm = conley_form, df = conley_smith_data, max_splines = 10)),
 tar_target(plb_check,
            spatInfer::placebo(fm = conley_form,
                               df = conley_smith_data,
                               splines = 10,
                               pc_num = 71)),
 tar_target(synth_check,
            spatInfer::synth(fm = conley_form,
                             df = conley_smith_data,
                             splines = 10,
                             pc_num = 71)),
 tar_target(make_weighting_data,
            add_weights_cs(weighting_data = conley_smith_data, 
            rhs = c("med_schools_ind","logww1", "verdun_petain", "palpha1935", "perrev1935", "etranger1935"),
            lhs = 'treated')),
 tar_target(weighted_placebo_check,
           spatInfer::placebo(fm = conley_form,
                              df = make_weighting_data,
                              splines = 10,
                             pc_num = 71,
                             weights = TRUE)),
tar_target(weighted_synth,
           spatInfer::synth(fm = conley_form,
                            df = make_weighting_data,
                            splines = 10,
                            pc_num = 71,
                            weights = TRUE)),
tar_target(synth_im_no_wts,
           spatInfer::synth_im(fm = conley_form,
                               df = conley_smith_data,
                               splines = 10,
                               pc_num = 71)),
tar_target(synth_im_wts,
           spatInfer::synth_im(fm = conley_form,
                               df = make_weighting_data,
                               splines = 10,
                               pc_num = 71,
                               weights = TRUE)))


