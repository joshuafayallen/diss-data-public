from greyblueguppy.mdjfscrapper import Scraper


sc = Scraper()

# scrapes just the letter p 
just_the_letter_p = sc.scrape_letter(letter = 'P')

# scrapes the full memorial 

all_lets = sc.scrape_all()
