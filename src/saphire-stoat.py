# This is an example of how to use the script
# I am trying to keep it nice and minimal but this is the general idea
# The file sizes are massive so putting them on github is def not viable 


from saphirestoat.data_collection import Data_Collection
from saphirestoat.process_data import Process_Comments



my_months = range(1,13)

my_years = [2016, 2020, 2023]

dc = Data_Collection(
    output_dir='data',
    years = [2021],
    months = [1]
)


dc.collect_data()

my_keywords  = ["Shoah", "vel d'hiv", "Gurs", "Drancy", "Petain", "Laval", "Darlan", "Le Pen", 'Eichman', "étoile jaune", "Vichy", 'Gas chambers',  "Zemmour", "Auschwitz", 'Soros', 'yellow star', 'anne frank', "never again", "Le Chambon-sur-Lignon", "Dreyfus Affair", "Alfred Dreyfus", "Aushwitz", "hitler",  "Zionism", "October 7th", "aryanization", "concentration camp", "concentration camps", "arbeit mach frei", "Simone Veil", "Covid", "gas chambers",  "deportation", "UGIF", "the Final solution",  "migrants",  "Judenraete", 'jews', 'cultural marxism', 'hollywood', 'new york', 'israel', 'conspiracy', 'bolshevism', 'epidemics', 'globalist', 'holocaust', 'kristallnacht', 'war crimes', 'genocide', 'warsaw ghetto', 'kikes', 'swastika', 'goym', 'holocaust extorition', 'zionists', 'jewish cabal', 'rockefeller', 'zylkon b', 'leuchter report', 'david irving', 'himmler', 'heydrich', 'wehrmacht', 'gestapo', 'world jewry', 'freemasonry', 'germar rudolf', 'ernest zundel', 'wansee','wansee conference', 'yad vashem', 'otto frank', "schindler's list", 'elie wiesel', 'treblinka', 'warsaw ghetto', 'chelmno', 'dachau', 'bergen-belsen', 'buchenwald', 'sobibor', 'belzec','bełzec', 'majdanek','sobibór' , 'chełmo' ,'zundel', 'zündel', 'viktor frankl', 'simon wiesenthal', 'babi yar', 'serge klarsfeld', 'klarsfeld', 'beate klarsfeld', 'paul rassinier', 'rassinier', 'faurisson', 'majdanek', 'hydrogen-cyanide', 'walter lüftl', 'walter luftl', 'luftl', 'friedrich berg', 'jean-claude pressac', 'pressac', 'mass graves', 'david cole', 'dresden', 'rommmel', 'thomas dalton', 'deborah liostadt', 'lipstadt', 'book burning', 'extermination order', 'raul hildberg', 'pogram', 'einsatzgruppen', 'killing squads', 'jewish terrorism', 'brown shirts', 'holocaust orthodoxy', 'carlo mattogno' ,'jewish lobby', 'aipac', 'holocaust revisionist', 'danuta czech', 'aktion reinhardt', 'reinhard camps', 'reinhardt', 'auschwitz lie', 'josef mengle', 'sscutzstaffel', 'lodz', 'holohoax', 'thomas dalton debates', 'babyn yar', 'ponary', 'kakamianets-podilskyi', 'bielski' , 'sonderkommando', 'trawniki', 'bielski brothers', 'warsaw ghetto uprisings', 'warsaw ghetto uprisings', 'lubetkin', 'zivia lubetkin', 'zuckerman', 'rudolf hoss', 'hoss']


clean_up = Process_Comments(
    keywords= my_keywords,
    input_file= ['data/comments/RC_2023-11.zst']
)

clean_up.convert_zst_to_csv()


sampled = clean_up.process_file(input_data=['data/comments/RC_2023-11.csv'],
                                sample = True)


# this is much faster
check_full = sampled.collect(engine = 'streaming')
