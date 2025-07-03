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





## instead of hard coding all the locals into the functions we should probably just do this a little bit more delicately for the 
## main analysis 


relg_verdun_elect_share = c("logww1", "verdun_petain", elect_religious,
                            "palpha1901", # these are literacy variables
                            "palpha1902","palpha1903","palpha1904","palpha1905","palpha1906",
                            "palpha1907","palpha1908","palpha1909","palpha1910","palpha1911",
                            "palpha1912","palpha1913","palpha1914","palpha1915","palpha1916",
                            "palpha1917","palpha1918","palpha1919","palpha1920","palpha1921",
                            "palpha1922","palpha1923","palpha1924","palpha1925","palpha1926",
                            "palpha1927","palpha1928","palpha1929","palpha1930","palpha1931",
                            "palpha1932","palpha1933","palpha1934","palpha1935","palpha1936",
                            "palpha1937","palpha1938","palpha1939", "perrev1919","perrev1920","perrev1921","perrev1922", # the perrev variables are 
                            "perrev1923","perrev1924","perrev1925","perrev1926","perrev1927",
                            "perrev1928","perrev1929","perrev1930","perrev1931",
                            "perrev1932","perrev1933","perrev1934","perrev1935",
                            "perrev1936","perrev1937","perrev1938","perrev1939","recette1911","recette1920",
                            "etranger1919","etranger1920", # these are immigration variables
                            "etranger1921","etranger1922","etranger1923","etranger1924",
                            "etranger1925","etranger1926","etranger1927","etranger1928",
                            "etranger1929","etranger1930","etranger1931","etranger1932",
                            "etranger1933","etranger1934","etranger1935","etranger1936","etranger1937","etranger1938","etranger1939")      


far_right_inclusive = c('pvoix_tixiervignancour_1965', 'pvoix_lepen_1974', 'pvoix_lepen_1988', 'pvoix_lepen_1995',
'pvoix_lepen_2002', 'pvoix_lepen_2007', 'pvoix_lepen_2007',
'pvoix_mlepen_2012', 'pvoix_mlepen_2017')


