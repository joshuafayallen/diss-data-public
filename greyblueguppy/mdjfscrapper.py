import time 
import string
import io
import traceback
from typing import Sequence, Optional, Type, Any 
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys 
from itertools import cycle, islice 
from selenium import webdriver
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.support.ui import Select
import polars as pl 
import polars.selectors as cs
from selenium.webdriver.common.alert import Alert 
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException,NoSuchElementException
import re
from urllib.parse import unquote


def clean_html_tags(text: str = None):
    """Extract all URLs from href attributes, or return clean text if no URLs found"""
    if not text:
        return text

    # First handle escaped quotes and backslashes
    text = re.sub(r'\\+', '', text)

    # Extract URLs from href attributes - handles various quote patterns
    url_patterns = [
        r'href=["\']([^"\']+)["\']',  # Standard href="url" or href='url'
        r'href=([^"\s>]+)',           # href=url without quotes
    ]

    urls = []
    for pattern in url_patterns:
        found_urls = re.findall(pattern, text)
        urls.extend(found_urls)

    # If we found URLs, return all of them separated by semicolons
    if urls:
        # Remove duplicates while preserving order
        unique_urls = []
        for url in urls:
            if url not in unique_urls:
                unique_urls.append(url)
        return '; '.join(unique_urls)
    
    return text


class Scraper:
    """
    This is a refactored version of the Memorial to The Deported Jews of France(MDJF) scrapper that I used in my dissertation. This method is more robust than the Rvest version, but by neccessity has some stuff hand coded 
    Attributes: 
        url: This is the url of the MDJF 
        lets_sub: Letters that you want to scrape. This is corresponds with the last name in the search parameters
        driver: a selenium webdriver. I relied on FireFox, but more advanced users can pass any Selenium driver
    Methods:
        _process_webpage: an internal function to process the webpage
        _parse_js_function_call: an internal function to parse the output from the hyperlink in the surname column
        _params_to_dict: an internal helper function to construct a dictionary to pass to polars
        _clean_html_tags: an internal heplper function to extract hyperrefs from the underlying data
        _make_driver: an internal helper to create selenium driver
        _close_driver: just closes the driver
        scrape_letter: scrapes one letter in the MDJF 
        scrape_all_letters: scrapes the entire MDJF 
    """
    def __init__(self,
                 url: str = 'https://stevemorse.org/france/indexe.html',
                 lets_sub: Sequence[str] = None,
                 driver: Optional[WebDriver] = None,
                 driver_cls: Optional[Type[WebDriver]] = None,
                 driver_options: Optional[Any] = None,
                 headless: bool = True):
        if lets_sub is None:
            lets_sub = list(string.ascii_uppercase)
        self.url = url
        self.lets_sub = lets_sub
        self.all_data = pl.DataFrame()
        self._close_driver_on_exit = False
        if driver:
            self.driver = driver
        else:
            self.driver = self._make_driver(
                driver_cls = driver_cls,
                driver_options = driver_options,
                headless = headless
            )
            self._close_driver_on_exit = True
    
    def _make_driver(self,
                    driver_cls: Optional[Type[WebDriver]] = None,
                    driver_options: Optional[Any] = None,
                    headless:bool = True) -> WebDriver:
        """
        Creates WebDriver. Default is Firefox 
        """
        if driver_cls is None:
            driver_cls = webdriver.Firefox
        if driver_options is None:
            if driver_cls == webdriver.Firefox:
                driver_options = webdriver.FirefoxOptions()
            elif driver_cls == webdriver.Chrome:
                driver_options = webdriver.ChromeOptions()
            else:
                driver_options = None
        if driver_options and hasattr(driver_options, "add_argument") and headless:
            driver_options.add_argument("--headless")
        if driver_options:
            return driver_cls(options = driver_options)
        else:
            return driver_cls()
    
    def close_driver(self):
        """Close the Selenium driver if it was created by this scraper."""
        if getattr(self, "_close_driver_on_exit", False) and hasattr(self, "driver") and self.driver:
            self.driver.quit()
        print("Driver closed.")
    
    def _parse_js_function_call(self, js_string:str = None):
        js_string = js_string if js_string is not None else self.js_string
        pattern = r"ShowDetails\((.*)\);"
        match = re.search(pattern, js_string)
        if not match:
            return None
    
        params_str = match.group(1)
    
        params = []
        current_param = ""
        in_quotes = False
        escape_next = False
    
        for char in params_str:
            if escape_next:
                current_param += char
                escape_next = False
            elif char == '\\':
                current_param += char
                escape_next = True
            elif char == "'" and not escape_next:
                in_quotes = not in_quotes
                current_param += char
            elif char == ',' and not in_quotes:
                params.append(current_param.strip())
                current_param = ""
            else:
                current_param += char
    
        if current_param.strip():
            params.append(current_param.strip())
    
        cleaned_params = []
        for param in params:
            param = param.strip("'\"")
            try:
                param = unquote(param)
            except:
                pass
            cleaned_params.append(param)
    
        return cleaned_params
    
    def _params_to_dict(self, params: str = None):
        params = params if params is not None else self.params
        if len(params) < 41:
            params.extend([''] * (41 - len(params)))

        result = {}
        result['surname'] = params[0]
        result['given_name'] = params[1]

        if params[2]:
            result['maiden_name'] = params[2]

        if params[3]:
            result['gender'] = params[3]

        if params[4]:
            result['age'] = params[4]

        if params[5]:
            result['birth_date'] = params[5]

        birth_place_parts = [params[9], params[14], params[15]]
        if any(birth_place_parts):
            result['birth_place'] = ', '.join(filter(None, birth_place_parts))

        if params[10]:
            result['birth_place_link'] = clean_html_tags(params[10])

        if params[12]:
            result['town_nearby_birthplace'] = params[12]

        if params[17]:
            result['yad_vashem_page_of_testimony'] = clean_html_tags(params[17])

        if params[19]:
            result['other_sources'] = clean_html_tags(params[19])

        address_parts = [params[22], params[23], params[24]]
        if any(address_parts):
            result['address'] = ', '.join(filter(None, address_parts))

        if params[26]:
            result['internment_transit_camp'] = params[26]

        if params[27]:
            result['convoy'] = params[27]

        if params[28]:
            result['klarsfeld_mdjf_entry'] = clean_html_tags(params[28])

        if params[29]:
            result['date_of_convoy'] = params[29]

        if params[30]:
            result['convoy_origin'] = params[30]
        if params[33]:
            result['fate'] = params[33]

        if params[31]:
            result['convoy_destination'] = params[31]

        if len(params) > 38 and params[38]:
            result['note'] = params[38]

        if len(params) > 40 and params[40]:
            result['permalink'] = params[40]

        return result

    def _clean_html_tags(self, text: str = None):
        """This method now calls the standalone function"""
        text = text if text is not None else self.text
        return clean_html_tags(text)

    def _process_webpage(self) -> pl.DataFrame:
        """
        Process current page and return list of parsed dicts.
        """
        xpath  = '/html/body/center/table/tbody/tr/td[3]/a'  
        WebDriverWait(self.driver, 90).until(
            EC.presence_of_all_elements_located((By.XPATH, xpath))
        )
        elements = self.driver.find_elements(By.XPATH, xpath)
        get_text = [txt.get_attribute('href') for txt in elements]
        clean_text = [self._parse_js_function_call(txt) for txt in get_text if txt]
        dicts = [self._params_to_dict(params) for params in clean_text]

        return pl.DataFrame(dicts)

    def scrape_letter(
        self,
        letter: str,
        url: Optional[str] = None,
        driver: Optional[WebDriver] = None
    ) -> pl.DataFrame:
        """
        Scrape all pages for a single starting letter.
        """
        if url is not None:
            self.url = url
        
        if letter is None:
            raise ValueError("letter is None; please provide a letter to scrape")

        use_existing_driver = driver is not None or hasattr(self, 'driver')
        
        if driver is not None:
            current_driver = driver
        elif hasattr(self, 'driver') and self.driver:
            current_driver = self.driver
        else:
            current_driver = self._make_driver()

        try:
            current_driver.get(self.url)

            # Fill out the search form - use current_driver instead of driver
            surname_input = WebDriverWait(current_driver, 30).until(
                EC.presence_of_element_located((
                    By.CSS_SELECTOR,
                    'body > form > div.content > table:nth-child(8) > tbody > tr > td:nth-child(3) > input'
                ))
            )
            surname_kind_select = current_driver.find_element(
                By.CSS_SELECTOR,
                'body > form > div.content > table:nth-child(8) > tbody > tr > td:nth-child(2) > select'
            )
            surname_input.send_keys(letter)
            Select(surname_kind_select).select_by_visible_text('starts with')

            submit_button = current_driver.find_element(By.XPATH, '/html/body/form/div[2]/input[35]')
            submit_button.click()

            # Switch to new window/tab
            WebDriverWait(current_driver, 30).until(lambda d: len(d.window_handles) > 1)
            current_driver.switch_to.window(current_driver.window_handles[1])

            WebDriverWait(current_driver, 90).until(
                EC.presence_of_element_located((By.XPATH, '/html/body/center/table'))
            )

            # Store current driver for _process_webpage method
            original_driver = getattr(self, 'driver', None)
            self.driver = current_driver

            # First page data
            letter_dat = self._process_webpage()

            # Loop through pagination
            while True:
                try:
                    next_button = WebDriverWait(current_driver, 90).until(
                        EC.element_to_be_clickable((By.LINK_TEXT, 'Next 50 entries'))
                    )
                    next_button.click()

                    WebDriverWait(current_driver, 90).until(
                        EC.presence_of_element_located((By.XPATH, '/html/body/center/table'))
                    )
                    current_dat = self._process_webpage()
                    letter_dat = pl.concat([letter_dat, current_dat], how='diagonal')
                    time.sleep(20)

                except (NoSuchElementException, TimeoutException):
                    print(f"Finished pagination for: {letter}")
                    break

            print(f"Collected {letter_dat.height} rows for: {letter}")
            
            if original_driver:
                self.driver = original_driver
            
            return letter_dat

        except Exception as e:
            tb = traceback.format_exc()
            print(f"Error scraping {letter}:\n{tb}")
            return pl.DataFrame()

        finally:
            if not use_existing_driver:
                current_driver.quit()

    def scrape_all(self):
        """Scrape all letters using the instance's driver"""
        for letter in self.lets_sub:
            print(f"Scraping letter: {letter}")
            letter_data = self.scrape_letter(letter)
            self.all_data = pl.concat([self.all_data, letter_data], how='diagonal')

        print(f"\n✅ Finished scraping all letters. Total rows: {self.all_data.height}")
        return self.all_data