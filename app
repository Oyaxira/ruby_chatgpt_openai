#!/usr/bin/env ruby
APP_ROOT = __dir__
require_relative 'config/application'
Chatgpt.initialize!
puts '初始化完成'
puts '第一次使用请在config/service_cache.yml的cookies中填入网页复制的cookies'
Chatgpt::AiConversation::SERVICE_CACHE
require 'irb'
require 'irb/completion'
include Chatgpt::Console
ARGV.clear
chat_help
IRB.start
