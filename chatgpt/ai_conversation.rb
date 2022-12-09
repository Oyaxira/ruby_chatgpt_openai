class Chatgpt::AiConversation
  begin
    SERVICE_CACHE = YAML.load_file "#{APP_ROOT}/config/service_cache.yml"
  rescue StandardError => e
    SERVICE_CACHE = { "cookies": '' }.as_json
    puts '一次使用请在config/service_cache.yml的cookies中填入网页复制的cookies'
    puts '输入exit退出'
    File.open("#{APP_ROOT}/config/service_cache.yml", 'w') do |f|
      f.write SERVICE_CACHE.to_yaml
    end
    SERVICE_CACHE = YAML.load_file "#{APP_ROOT}/config/service_cache.yml"
  end

  class << self
    def get_header
      authorization_token = SERVICE_CACHE['authorization_token']
      if authorization_token.blank?
        parse_origin_cookies
        get_new_session
        authorization_token = SERVICE_CACHE['authorization_token']
      end
      last_cookies_at = SERVICE_CACHE['last_cookies_at']
      get_new_session if last_cookies_at.nil? || Time.current.to_i - last_cookies_at > 300
      {
        "accept": 'text/event-stream',
        "accept-language": 'zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7,zh-TW;q=0.6',
        "authorization": "Bearer #{authorization_token}",
        "cache-control": 'no-cache',
        "content-type": 'application/json',
        "pragma": 'no-cache',
        "cookie": SERVICE_CACHE['cookie_data'],
        "dnt": 1,
        "referer": 'https://chat.openai.com/chat',
        "origin": 'https://chat.openai.com',
        "sec-ch-ua": '"Not?A_Brand";v="8", "Chromium";v="108", "Google Chrome";v="108"',
        "sec-ch-ua-mobile": '?0',
        "sec-ch-ua-platform": '"macOS"',
        "sec-fetch-dest": 'empty',
        "sec-fetch-mode": 'cors',
        "sec-fetch-site": 'same-origin',
        "user-agent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
        "x-openai-assistant-app-id": ''
      }
    end

    def get_new_session
      header = {
        "accept": '*/*',
        "accept-language": 'zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7,zh-TW;q=0.6',
        "cache-control": 'no-cache',
        "content-type": 'application/json',
        "pragma": 'no-cache',
        "cookies": SERVICE_CACHE['cookie_data'],
        "dnt": 1,
        "referer": 'https://chat.openai.com/chat',
        "sec-ch-ua": '"Not?A_Brand";v="8", "Chromium";v="108", "Google Chrome";v="108"',
        "sec-ch-ua-mobile": '?0',
        "sec-ch-ua-platform": '"macOS"',
        "sec-fetch-dest": 'empty',
        "sec-fetch-mode": 'cors',
        "sec-fetch-site": 'same-origin',
        "user-agent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
      }
      response = RestClient.get('https://chat.openai.com/api/auth/session', header)
      SERVICE_CACHE['cookie_data'] = response.cookies
      SERVICE_CACHE['last_cookies_at'] = Time.current.to_i
      result = JSON.parse response.body
      accessToken = result['accessToken']
      SERVICE_CACHE['authorization_token'] = accessToken
      save_service_cache
      response
    end

    def save_service_cache
      File.open("#{APP_ROOT}/config/service_cache.yml", 'w') do |f|
        f.write SERVICE_CACHE.to_yaml
      end
    end

    def get_reply(body)
      response = RestClient.post('https://chat.openai.com/backend-api/conversation', body.to_json, get_header)
      final_data = response.body.split("\n\n")[-2]
      final_data = final_data.gsub(/^data: /, '')
      result = JSON.parse(final_data)
    end

    def parse_origin_cookies
      origin_cookies = CGI::Cookie.parse(SERVICE_CACHE['cookies'])
      cookies = {}
      origin_cookies.as_json.each do |key, value|
        cookies[key] = value[0]
      end
      SERVICE_CACHE['cookie_data'] = cookies
      save_service_cache
    end
  end
end
