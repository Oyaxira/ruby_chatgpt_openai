module Chatgpt::Console
  extend self
  def first_call(prompt = '你好, 世界')
    Conversation.first_call prompt
  end

  def last(n = 1)
    conversation = Conversation.all.order(created_at: :desc).limit(n).last
    conversation.display
    conversation
  end

  def export_all
    dir_path = "#{APP_ROOT}/exports"
    Dir.mkdir(dir_path) unless Dir.exist?(dir_path)
    filename = "#{Time.current.to_i}.txt"
    file_data = ''
    Conversation.all.each do |conversation|
      data = "\n你: #{conversation.prompt}\nChatGPT: #{conversation.answer}\n"
      file_data += data
    end
    file_path = "#{dir_path}/#{filename}"
    File.open(file_path, 'w') do |f|
      f.write file_data
    end
    puts "文件已经导出至当前目录下exports/#{filename}"
  end

  def chat_help
    puts "con = first_call '你好' #进行第一次会话"
    puts 'con = last #最近的一挑会话数据'
    puts 'con = last(3) #最近的第三条会话数据'
    puts "con = con.reply '在吗?' #回复这条对话,con对象会变为最新的对话"
    puts 'con #查看con对象详细信息'
    puts 'con = Conversation.find(id) #查找某个id的conversation 参考active record文档'
    puts 'chathelp #查看此帮助'
    puts 'export #导出本地数据'
  end
end
