# this is the scrapper that was used originally to scrape the mdjf

pacman::p_load("rvest", "tidyverse", "robotstxt", "httr", "polite", "furrr", "robotstxt")
 
 
pre_fix = "https://stevemorse.org/france/see.php?SurnameNomKind=starts&SurnameNomSoundex=&SurnameNomMax="
 
suff_fix = "&GivenNamePrnomKind=starts&GivenNamePrnomSoundex=&GivenNamePrnomMax=&MaidennameNomdejeunefilleKind=sounds&MaidennameNomdejeunefilleSoundex=&MaidennameNomdejeunefilleMax=&SexKind=exact&SexMax=&AgeKind=between&AgeMin=&AgeMax=&DateofbirthDatedenaissanceKind=exact&DateofbirthDatedenaissanceMax=&DayofbirthJourdenaissanceKind=exact&DayofbirthJourdenaissanceMax=&MonthofbirthMoisdenaissanceKind=exact&MonthofbirthMoisdenaissanceMax=&YearofbirthAnnedenaissanceKind=exact&YearofbirthAnnedenaissanceMax=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsKind=sounds&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsSoundex=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsMax=&PlaceofbirthLieudenaissanceKind=exact&PlaceofbirthLieudenaissanceMax=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceKind=exact&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceSoundex=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceMax=&TownnearbybirthplaceVillevoisinedulieudenaissanceKind=exact&TownnearbybirthplaceVillevoisinedulieudenaissanceMax=&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceKind=exact&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceMax=&RegionofbirthRgionDpartementdenaissanceKind=exact&RegionofbirthRgionDpartementdenaissanceSoundex=&RegionofbirthRgionDpartementdenaissanceMax=&CountryofbirthPaysdenaissanceKind=exact&CountryofbirthPaysdenaissanceMax=&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Kind=exact&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Max=&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielKind=exact&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielMax=&JournalOfficielAnnouncementAnnonceKind=exact&JournalOfficielAnnouncementAnnonceMax=&OthersourcesAutressourcesKind=exact&OthersourcesAutressourcesMax=&CitizenofNationalitKind=exact&CitizenofNationalitMax=&AddressAdresseKind=exact&AddressAdresseMax=&AddressstreetAdresserueKind=contains&AddressstreetAdresserueMax=&AddresstownAdressevilleKind=exact&AddresstownAdressevilleSoundex=&AddresstownAdressevilleMax=&AddressdepartmentAdressedpartementKind=exact&AddressdepartmentAdressedpartementMax=&InternmentTransitCampCampdinternementoudetransitKind=exact&InternmentTransitCampCampdinternementoudetransitMax=&ConvoyconvoiKind=exact&ConvoyconvoiMax=&ConvoyNumberNumrodeconvoiKind=exact&ConvoyNumberNumrodeconvoiMax=&DateofconvoyDateduconvoiKind=exact&DateofconvoyDateduconvoiMax=&ConvoyoriginConvoipartideKind=exact&ConvoyoriginConvoipartideMax=&ConvoydestinationDestinationduconvoiKind=exact&ConvoydestinationDestinationduconvoiMax=&PrisonerNumberMatriculeKind=exact&PrisonerNumberMatriculeMax=&SurvivorSurvivantKind=exact&SurvivorSurvivantMax=&DateofdeathDatededcsKind=exact&DateofdeathDatededcsMax=&PlaceofdeathLieudedcsKind=exact&PlaceofdeathLieudedcsMax=&ProfessionKind=exact&ProfessionMax=&PhotoKind=exact&PhotoMax=&NotesKind=contains&NotesMax=&IdKind=exact&IdMax=&PermalinkKind=exact&PermalinkMax=&offset=1&pagesize=200"
 
 suffix_2 = "&GivenNamePrnomKind=starts&GivenNamePrnomSoundex=&GivenNamePrnomMax=&MaidennameNomdejeunefilleKind=sounds&MaidennameNomdejeunefilleSoundex=&MaidennameNomdejeunefilleMax=&SexKind=exact&SexMax=&AgeKind=between&AgeMin=&AgeMax=&DateofbirthDatedenaissanceKind=exact&DateofbirthDatedenaissanceMax=&DayofbirthJourdenaissanceKind=exact&DayofbirthJourdenaissanceMax=&MonthofbirthMoisdenaissanceKind=exact&MonthofbirthMoisdenaissanceMax=&YearofbirthAnnedenaissanceKind=exact&YearofbirthAnnedenaissanceMax=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsKind=sounds&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsSoundex=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsMax=&PlaceofbirthLieudenaissanceKind=exact&PlaceofbirthLieudenaissanceMax=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceKind=exact&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceSoundex=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceMax=&TownnearbybirthplaceVillevoisinedulieudenaissanceKind=exact&TownnearbybirthplaceVillevoisinedulieudenaissanceMax=&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceKind=exact&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceMax=&RegionofbirthRgionDpartementdenaissanceKind=exact&RegionofbirthRgionDpartementdenaissanceSoundex=&RegionofbirthRgionDpartementdenaissanceMax=&CountryofbirthPaysdenaissanceKind=exact&CountryofbirthPaysdenaissanceMax=&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Kind=exact&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Max=&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielKind=exact&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielMax=&JournalOfficielAnnouncementAnnonceKind=exact&JournalOfficielAnnouncementAnnonceMax=&OthersourcesAutressourcesKind=exact&OthersourcesAutressourcesMax=&CitizenofNationalitKind=exact&CitizenofNationalitMax=&AddressAdresseKind=exact&AddressAdresseMax=&AddressstreetAdresserueKind=contains&AddressstreetAdresserueMax=&AddresstownAdressevilleKind=exact&AddresstownAdressevilleSoundex=&AddresstownAdressevilleMax=&AddressdepartmentAdressedpartementKind=exact&AddressdepartmentAdressedpartementMax=&InternmentTransitCampCampdinternementoudetransitKind=exact&InternmentTransitCampCampdinternementoudetransitMax=&ConvoyconvoiKind=exact&ConvoyconvoiMax=&ConvoyNumberNumrodeconvoiKind=exact&ConvoyNumberNumrodeconvoiMax=&DateofconvoyDateduconvoiKind=exact&DateofconvoyDateduconvoiMax=&ConvoyoriginConvoipartideKind=exact&ConvoyoriginConvoipartideMax=&ConvoydestinationDestinationduconvoiKind=exact&ConvoydestinationDestinationduconvoiMax=&PrisonerNumberMatriculeKind=exact&PrisonerNumberMatriculeMax=&SurvivorSurvivantKind=exact&SurvivorSurvivantMax=&DateofdeathDatededcsKind=exact&DateofdeathDatededcsMax=&PlaceofdeathLieudedcsKind=exact&PlaceofdeathLieudedcsMax=&ProfessionKind=exact&ProfessionMax=&PhotoKind=exact&PhotoMax=&NotesKind=contains&NotesMax=&IdKind=exact&IdMax=&PermalinkKind=exact&PermalinkMax=&pagesize=200&offset=201"
 
 
 suffix_3 = "&GivenNamePrnomKind=starts&GivenNamePrnomSoundex=&GivenNamePrnomMax=&MaidennameNomdejeunefilleKind=sounds&MaidennameNomdejeunefilleSoundex=&MaidennameNomdejeunefilleMax=&SexKind=exact&SexMax=&AgeKind=between&AgeMin=&AgeMax=&DateofbirthDatedenaissanceKind=exact&DateofbirthDatedenaissanceMax=&DayofbirthJourdenaissanceKind=exact&DayofbirthJourdenaissanceMax=&MonthofbirthMoisdenaissanceKind=exact&MonthofbirthMoisdenaissanceMax=&YearofbirthAnnedenaissanceKind=exact&YearofbirthAnnedenaissanceMax=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsKind=sounds&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsSoundex=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsMax=&PlaceofbirthLieudenaissanceKind=exact&PlaceofbirthLieudenaissanceMax=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceKind=exact&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceSoundex=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceMax=&TownnearbybirthplaceVillevoisinedulieudenaissanceKind=exact&TownnearbybirthplaceVillevoisinedulieudenaissanceMax=&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceKind=exact&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceMax=&RegionofbirthRgionDpartementdenaissanceKind=exact&RegionofbirthRgionDpartementdenaissanceSoundex=&RegionofbirthRgionDpartementdenaissanceMax=&CountryofbirthPaysdenaissanceKind=exact&CountryofbirthPaysdenaissanceMax=&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Kind=exact&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Max=&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielKind=exact&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielMax=&JournalOfficielAnnouncementAnnonceKind=exact&JournalOfficielAnnouncementAnnonceMax=&OthersourcesAutressourcesKind=exact&OthersourcesAutressourcesMax=&CitizenofNationalitKind=exact&CitizenofNationalitMax=&AddressAdresseKind=exact&AddressAdresseMax=&AddressstreetAdresserueKind=contains&AddressstreetAdresserueMax=&AddresstownAdressevilleKind=exact&AddresstownAdressevilleSoundex=&AddresstownAdressevilleMax=&AddressdepartmentAdressedpartementKind=exact&AddressdepartmentAdressedpartementMax=&InternmentTransitCampCampdinternementoudetransitKind=exact&InternmentTransitCampCampdinternementoudetransitMax=&ConvoyconvoiKind=exact&ConvoyconvoiMax=&ConvoyNumberNumrodeconvoiKind=exact&ConvoyNumberNumrodeconvoiMax=&DateofconvoyDateduconvoiKind=exact&DateofconvoyDateduconvoiMax=&ConvoyoriginConvoipartideKind=exact&ConvoyoriginConvoipartideMax=&ConvoydestinationDestinationduconvoiKind=exact&ConvoydestinationDestinationduconvoiMax=&PrisonerNumberMatriculeKind=exact&PrisonerNumberMatriculeMax=&SurvivorSurvivantKind=exact&SurvivorSurvivantMax=&DateofdeathDatededcsKind=exact&DateofdeathDatededcsMax=&PlaceofdeathLieudedcsKind=exact&PlaceofdeathLieudedcsMax=&ProfessionKind=exact&ProfessionMax=&PhotoKind=exact&PhotoMax=&NotesKind=contains&NotesMax=&IdKind=exact&IdMax=&PermalinkKind=exact&PermalinkMax=&offset=401&pagesize=200"
 
 constructed_link = data.frame(lets = expand_grid(a  = LETTERS, b = LETTERS, c =  LETTERS)) |> 
   unite(combo,c("lets.a", "lets.b",  "lets.c"), sep = "") |> 
   mutate(links_one = paste0(pre_fix, combo, suff_fix),
          links_two = paste0(pre_fix, combo, suffix_2),
          id = row_number()) 
 
 
 
 
 memorial_scraper = function(link){
   
   session = bow(url = link, delay = 5,
                 user_agent = "Josh Allen jallen108@gsu.edu please contact with questions",
                 force = TRUE)
   
   
   cat("Starting to Scrape Last Names with", link, "\n")
   
   memorial_dat_raw =  scrape(session, content = "text/html; charset=UTF-8") |> 
     html_elements("table") |> 
     html_table(header = FALSE) |> 
     pluck(1)
   
   memorial_dat_fix_names = memorial_dat_raw |> 
     slice(-1) |> 
     janitor::row_to_names(row_number = 1) |> 
     janitor::clean_names() |> 
     select(-starts_with("na"), -starts_with("x"))
   
  cat("Finished Scraping Link", "\n")
  
  return(memorial_dat_fix_names)
  
   Sys.sleep(5)
   
   
   
 }
 
 
 pos_memorial_scrape = possibly(memorial_scraper)
 
 
 links_off_one = constructed_link  |> 
   select(links_one) |> 
   deframe()
 
 
 links_off_two = constructed_link |> 
   select(links_two) |> 
   deframe()
 
 
 
 
 results_mem_scrape_off_one = map(links_off_one, pos_memorial_scrape)
 
 results_df_raw_one = results_mem_scrape_off_one |> 
   compact() |> 
   list_rbind() 
 
  save one off data 
 
 write_csv(results_df_raw_one, here::here("data", "memorial-data-first-set-names.csv"))
 
  so this is here as a bit of trick
  the computer updated sometime overnight and you lost your progress
 
 
 result_me_scrape_off_two = map(links_off_two, pos_memorial_scrape)
 
 
 results_df_raw_two = result_me_scrape_off_two |> 
   compact() |> 
   list_rbind()
 
 write_csv(results_df_raw_two, here::here("data", "memorial-data-second-set.csv"))
 
 

 
 get_letters = results_df_raw_two |> 
   select(surname) |> 
    get first three letters 
   mutate(combo = str_extract(surname, "^.{3}")) |> 
   distinct(combo) |> 
   deframe()
 
 links_three = constructed_link |> 
   filter(combo %in% get_letters) |> 
   mutate(links_three = paste0(pre_fix, combo, suffix_3)) |> 
   select(links_three) |> 
   deframe()
 
 
 results_links_three = map(links_three, pos_memorial_scrape)
 
 df_links_three = results_links_three |> 
   compact() |> 
   list_rbind()
 
 
 
 write_csv(df_links_three, here::here("data", "memorial-data-third-set.csv"))
 
 
 
 csvs_mem = list.files(path = "data/", pattern = "memorial-data", full.names = TRUE)
 
 read_data = map(csvs_mem, \(x) read_csv(here::here("data", x))) |> 
   list_rbind()
 
 arrow::write_parquet(raw_data, "data/memorial-full.parquet")
 
 write_csv(raw_data, "data/memorial-full.csv")
 
 
 

pacman::p_load("rvest", "tidyverse", "robotstxt", "httr", "polite", "furrr", "robotstxt")



pre_fix = "https://stevemorse.org/france/see.php?SurnameNomKind=starts&SurnameNomSoundex=&SurnameNomMax="

suff_fix = "&GivenNamePrnomKind=starts&GivenNamePrnomSoundex=&GivenNamePrnomMax=&MaidennameNomdejeunefilleKind=sounds&MaidennameNomdejeunefilleSoundex=&MaidennameNomdejeunefilleMax=&SexKind=exact&SexMax=&AgeKind=between&AgeMin=&AgeMax=&DateofbirthDatedenaissanceKind=exact&DateofbirthDatedenaissanceMax=&DayofbirthJourdenaissanceKind=exact&DayofbirthJourdenaissanceMax=&MonthofbirthMoisdenaissanceKind=exact&MonthofbirthMoisdenaissanceMax=&YearofbirthAnnedenaissanceKind=exact&YearofbirthAnnedenaissanceMax=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsKind=sounds&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsSoundex=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsMax=&PlaceofbirthLieudenaissanceKind=exact&PlaceofbirthLieudenaissanceMax=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceKind=exact&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceSoundex=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceMax=&TownnearbybirthplaceVillevoisinedulieudenaissanceKind=exact&TownnearbybirthplaceVillevoisinedulieudenaissanceMax=&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceKind=exact&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceMax=&RegionofbirthRgionDpartementdenaissanceKind=exact&RegionofbirthRgionDpartementdenaissanceSoundex=&RegionofbirthRgionDpartementdenaissanceMax=&CountryofbirthPaysdenaissanceKind=exact&CountryofbirthPaysdenaissanceMax=&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Kind=exact&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Max=&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielKind=exact&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielMax=&JournalOfficielAnnouncementAnnonceKind=exact&JournalOfficielAnnouncementAnnonceMax=&OthersourcesAutressourcesKind=exact&OthersourcesAutressourcesMax=&CitizenofNationalitKind=exact&CitizenofNationalitMax=&AddressAdresseKind=exact&AddressAdresseMax=&AddressstreetAdresserueKind=contains&AddressstreetAdresserueMax=&AddresstownAdressevilleKind=exact&AddresstownAdressevilleSoundex=&AddresstownAdressevilleMax=&AddressdepartmentAdressedpartementKind=exact&AddressdepartmentAdressedpartementMax=&InternmentTransitCampCampdinternementoudetransitKind=exact&InternmentTransitCampCampdinternementoudetransitMax=&ConvoyconvoiKind=exact&ConvoyconvoiMax=&ConvoyNumberNumrodeconvoiKind=exact&ConvoyNumberNumrodeconvoiMax=&DateofconvoyDateduconvoiKind=exact&DateofconvoyDateduconvoiMax=&ConvoyoriginConvoipartideKind=exact&ConvoyoriginConvoipartideMax=&ConvoydestinationDestinationduconvoiKind=exact&ConvoydestinationDestinationduconvoiMax=&PrisonerNumberMatriculeKind=exact&PrisonerNumberMatriculeMax=&SurvivorSurvivantKind=exact&SurvivorSurvivantMax=&DateofdeathDatededcsKind=exact&DateofdeathDatededcsMax=&PlaceofdeathLieudedcsKind=exact&PlaceofdeathLieudedcsMax=&ProfessionKind=exact&ProfessionMax=&PhotoKind=exact&PhotoMax=&NotesKind=contains&NotesMax=&IdKind=exact&IdMax=&PermalinkKind=exact&PermalinkMax=&offset=1&pagesize=200"

suffix_2 = "&GivenNamePrnomKind=starts&GivenNamePrnomSoundex=&GivenNamePrnomMax=&MaidennameNomdejeunefilleKind=sounds&MaidennameNomdejeunefilleSoundex=&MaidennameNomdejeunefilleMax=&SexKind=exact&SexMax=&AgeKind=between&AgeMin=&AgeMax=&DateofbirthDatedenaissanceKind=exact&DateofbirthDatedenaissanceMax=&DayofbirthJourdenaissanceKind=exact&DayofbirthJourdenaissanceMax=&MonthofbirthMoisdenaissanceKind=exact&MonthofbirthMoisdenaissanceMax=&YearofbirthAnnedenaissanceKind=exact&YearofbirthAnnedenaissanceMax=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsKind=sounds&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsSoundex=&PlaceofbirthnodiacriticsignsLieudenaissancesansaccentsMax=&PlaceofbirthLieudenaissanceKind=exact&PlaceofbirthLieudenaissanceMax=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceKind=exact&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceSoundex=&FormerothernameofbirthplaceAncienautrenomdulieudenaissanceMax=&TownnearbybirthplaceVillevoisinedulieudenaissanceKind=exact&TownnearbybirthplaceVillevoisinedulieudenaissanceMax=&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceKind=exact&HamletneighborhoodofbirthHameauouquartierdelacommunedenaissanceMax=&RegionofbirthRgionDpartementdenaissanceKind=exact&RegionofbirthRgionDpartementdenaissanceSoundex=&RegionofbirthRgionDpartementdenaissanceMax=&CountryofbirthPaysdenaissanceKind=exact&CountryofbirthPaysdenaissanceMax=&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Kind=exact&Placeofbirthin2012MemorialLieudenaissancedansleMmorialde2012Max=&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielKind=exact&PlaceofbirthinJournalOfficielLieudenaissanceauJournalOfficielMax=&JournalOfficielAnnouncementAnnonceKind=exact&JournalOfficielAnnouncementAnnonceMax=&OthersourcesAutressourcesKind=exact&OthersourcesAutressourcesMax=&CitizenofNationalitKind=exact&CitizenofNationalitMax=&AddressAdresseKind=exact&AddressAdresseMax=&AddressstreetAdresserueKind=contains&AddressstreetAdresserueMax=&AddresstownAdressevilleKind=exact&AddresstownAdressevilleSoundex=&AddresstownAdressevilleMax=&AddressdepartmentAdressedpartementKind=exact&AddressdepartmentAdressedpartementMax=&InternmentTransitCampCampdinternementoudetransitKind=exact&InternmentTransitCampCampdinternementoudetransitMax=&ConvoyconvoiKind=exact&ConvoyconvoiMax=&ConvoyNumberNumrodeconvoiKind=exact&ConvoyNumberNumrodeconvoiMax=&DateofconvoyDateduconvoiKind=exact&DateofconvoyDateduconvoiMax=&ConvoyoriginConvoipartideKind=exact&ConvoyoriginConvoipartideMax=&ConvoydestinationDestinationduconvoiKind=exact&ConvoydestinationDestinationduconvoiMax=&PrisonerNumberMatriculeKind=exact&PrisonerNumberMatriculeMax=&SurvivorSurvivantKind=exact&SurvivorSurvivantMax=&DateofdeathDatededcsKind=exact&DateofdeathDatededcsMax=&PlaceofdeathLieudedcsKind=exact&PlaceofdeathLieudedcsMax=&ProfessionKind=exact&ProfessionMax=&PhotoKind=exact&PhotoMax=&NotesKind=contains&NotesMax=&IdKind=exact&IdMax=&PermalinkKind=exact&PermalinkMax=&offset=201&pagesize=200"


constructed_link = data.frame(lets = expand_grid(a  = LETTERS, b = LETTERS, c =  LETTERS)) |> 
  unite(combo,c("lets.a", "lets.b",  "lets.c"), sep = "") |> 
  mutate(links_one = paste0(pre_fix, combo, suff_fix),
         links_two = paste0(pre_fix, combo, suffix_2)) 




memorial_scraper = function(link){
  
  session = bow(url = link, delay = 5,
                user_agent = "Josh Allen jallen108@gsu.edu please contact with questions",
                force = TRUE)
  
  
  cat("Starting to Scrape Last Names with", link, "\n")
  
  memorial_dat_raw =  scrape(session, content = "text/html; charset=UTF-8") |> 
    html_elements("table") |> 
    html_table(header = FALSE) |> 
    pluck(1)
  
  memorial_dat_fix_names = memorial_dat_raw |> 
    slice(-1) |> 
    janitor::row_to_names(row_number = 1) |> 
    janitor::clean_names() |> 
    select(-starts_with("na"), -starts_with("x"))
  
 cat("Finished Scraping Link", "\n")
 
 return(memorial_dat_fix_names)
 
  Sys.sleep(5)
  
  
  
}


pos_memorial_scrape = possibly(memorial_scraper)


links_off_one = constructed_link  |> 
  select(links_one) |> 
  deframe()


links_off_two = constructed_link |> 
  select(links_two) |> 
  deframe()




results_mem_scrape_off_one = map(links_off_one, pos_memorial_scrape)

results_df_raw_one = results_mem_scrape_off_one |> 
  compact() |> 
  list_rbind() 



write_csv(results_df_raw_one, here::here("data", "memorial-data-first-set-names.csv"))


result_me_scrape_off_two = map(links_off_two, pos_memorial_scrape)