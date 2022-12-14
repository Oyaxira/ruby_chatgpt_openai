require 'active_record'
module Chatgpt
  autoload :AiConversation, File.expand_path('./ai_conversation', __dir__)
  autoload :Console, File.expand_path('./console', __dir__)
  autoload :Chrome, File.expand_path('./chrome', __dir__)
  extend self
  CONFIG = YAML.load_file "#{APP_ROOT}/config/config.yml"
  def initialize!
    init_db
  end

  def init_db
    puts '初始化数据库'
    ActiveRecord::Base.establish_connection(CONFIG['db'])
    require "#{APP_ROOT}/chatgpt/models/conversation"
  end
end
