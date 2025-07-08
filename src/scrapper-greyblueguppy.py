# this will run the scrapper 

from greyblueguppy.mdjfscrapper import Scraper
import polars as pl
import string


# this is a little bit more robust since the MDJF is not the most well constructed website 
# so if you just submit a eventually it will go blank once it has a combo of letters that it doesn't have
# For example FM has no entries so the webpage will go blank and then the scrapper will think its done with the letter A 
lets1 = pl.DataFrame({'first_let': list(string.ascii_uppercase)})
lets2  = pl.DataFrame({'second_let': list(string.ascii_uppercase)})

lets_sub = lets1.join(lets2, how='cross').with_columns(
    pl.concat_str(['first_let', 'second_let']).alias('submission')
)['submission'].to_list()

sc = Scraper(headless=True,
             lets_sub=lets_sub)


mdjf = sc.scrape_all()
