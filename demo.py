import undetected_chromedriver as uc
import time
import redis
import random
r = redis.StrictRedis(host='127.0.0.1', port=6379, db=0, password='')
options = uc.ChromeOptions()

# options.headless=True
# options.add_argument('--headless')
# options.add_argument('--no-sandbox')
# options.add_argument('--kiosk')
# driver = uc.Chrome(options=options)
while True:
  driver = uc.Chrome()
  url = 'https://chat.openai.com/chat'
  driver.get(url)
  cf_clearance = ''
  while not cf_clearance:
    time.sleep(3)
    cookies_list = driver.get_cookies()
    cookies_dict = {}
    for cookie in cookies_list:
        cookies_dict[cookie['name']] = cookie['value']
    cf_clearance = cookies_dict.get('cf_clearance')
  r.set("cf_clearance", cf_clearance)
  driver.quit()
  sleep_time = random.randint(1400,2400)
  time.sleep(sleep_time)
