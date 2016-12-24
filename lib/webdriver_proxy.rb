require "selenium-webdriver"

class WebdriverProxy
  def initialize(browser_type, page_load_timeout=2,implicit_wait_timeout=20)
    @driver = Selenium::WebDriver.for browser_type
    @driver.manage.timeouts.page_load = page_load_timeout #secodns
    @driver.manage.timeouts.implicit_wait = implicit_wait_timeout #secodns
  end
  
  def goto(url)
    @driver.navigate.to url
  end

  def title
    @driver.title
  end

  def url
    @driver.url
  end

  def page_source
    @driver.page_source
  end

  def find_elements_by_xpath (xpath)
    @driver.find_elements(:xpath, xpath)
  end

  def close
    @driver.quit
  end
end
