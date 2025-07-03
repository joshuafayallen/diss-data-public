
class Scraper:
    def __init__(self, url, lets_sub):
        self.url = url
        self.lets_sub = lets_sub
        self.all_data = pl.DataFrame()

    def process_webpage(self, driver):
        """
        Process current page and return list of parsed dicts.
        """
        return process_webpage(driver)

    def scrape_letter(self, letter):
        driver = webdriver.Firefox()
        driver.get(self.url)

        try:
            surname_input = WebDriverWait(driver, 30).until(
                EC.presence_of_element_located(
                    (By.CSS_SELECTOR,
                     'body > form > div.content > table:nth-child(8) > tbody > tr > td:nth-child(3) > input')
                )
            )
            surname_kind_select = driver.find_element(
                By.CSS_SELECTOR,
                'body > form > div.content > table:nth-child(8) > tbody > tr > td:nth-child(2) > select'
            )
            surname_input.send_keys(letter)
            Select(surname_kind_select).select_by_visible_text('starts with')

            submit_button = driver.find_element(By.XPATH, '/html/body/form/div[2]/input[35]')
            submit_button.click()

            WebDriverWait(driver, 30).until(lambda d: len(d.window_handles) > 1)
            driver.switch_to.window(driver.window_handles[1])

            WebDriverWait(driver, 90).until(
                EC.presence_of_element_located((By.XPATH, '/html/body/center/table'))
            )
            letter_dat = pl.DataFrame(self.process_webpage(driver))

            while True:
                try:
                    next_button = WebDriverWait(driver, 10).until(
                        EC.element_to_be_clickable((By.XPATH, '/html/body/center/a[2]'))
                    )
                    next_button.click()

                    WebDriverWait(driver, 90).until(
                        EC.presence_of_element_located((By.XPATH, '/html/body/center/table'))
                    )
                    current_dat = pl.DataFrame(self.process_webpage(driver))
                    letter_dat = pl.concat([letter_dat, current_dat], how='diagonal')
                    time.sleep(1)

                except (NoSuchElementException, TimeoutException):
                    print(f"Finished pagination for: {letter}")
                    break

            print(f"Collected {letter_dat.height} rows for: {letter}")
            return letter_dat

        except Exception as e:
            print(f"Error scraping letter {letter}: {e}")
            return pl.DataFrame()

        finally:
            driver.quit()

    def scrape_all(self):
        for letter in self.lets_sub:
            print(f"Scraping letter: {letter}")
            letter_data = self.scrape_letter(letter)
            self.all_data = pl.concat([self.all_data, letter_data], how='diagonal')

        print(f"\n✅ Finished scraping all letters. Total rows: {self.all_data.height}")
        return self.all_data
