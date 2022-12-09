# t.text :prompt
# t.text :answer
# t.string :conversation_id
# t.string :message_id
# t.boolean :is_fav
class Conversation < ActiveRecord::Base
  has_many :children, class_name: 'Conversation', foreign_key: :parent_id, primary_key: :message_id
  belongs_to :parent, class_name: 'Conversation', foreign_key: :parent_id, primary_key: :message_id, optional: true

  def self.last_message(conversation_id = nil)
    last_message = nil
    if conversation_id
      Conversation.where(conversation_id: conversation_id).order(created_at: :desc).limit(1).first
    else
      Conversation.last
    end
  end

  def self.first_call(prompt = '你好,世界')
    uuid = SecureRandom.uuid
    body = {
      'action' => 'next',
      'messages' => [
        {
          'id' => uuid,
          'role' => 'user',
          'content' => { 'content_type' => 'text', 'parts' => [prompt] }
        }
      ],
      'parent_message_id' => SecureRandom.uuid,
      'model' => 'text-davinci-002-render'
    }
    result = Chatgpt::AiConversation.get_reply(body)
    message = result['message']
    conversation = Conversation.new
    conversation.prompt = prompt
    conversation.answer = message['content']['parts'][0]
    conversation.conversation_id = result['conversation_id']
    conversation.message_id = message['id']
    conversation.save
    conversation.display
    conversation
  end

  def reply(new_prompt = '什么?')
    uuid = SecureRandom.uuid
    body = {
      'action' => 'next',
      'messages' => [
        {
          'id' => uuid,
          'role' => 'user',
          'content' => { 'content_type' => 'text', 'parts' => [new_prompt] }
        }
      ],
      'conversation_id' => conversation_id,
      'parent_message_id' => message_id,
      'model' => 'text-davinci-002-render'
    }
    result = Chatgpt::AiConversation.get_reply(body)

    message = result['message']
    conversation = dup
    conversation.prompt = new_prompt
    conversation.answer = message['content']['parts'][0]
    conversation.conversation_id = result['conversation_id']
    conversation.message_id = message['id']
    conversation.parent_id = message_id
    conversation.save
    conversation.display
    conversation
  end

  def display
    text = "你: #{prompt}\nChatGPT: \n#{answer}\n"
    puts text
    text
  end

  def export
    dir_path = "#{APP_ROOT}/exports"
    Dir.mkdir(dir_path) unless Dir.exist?(dir_path)
    filename = "#{conversation_id}.txt"
    datas = [self]
    target = parent
    until target.blank?
      datas.push target
      target = target.parent
    end
    file_data = ''
    datas.reverse.each do |conversation|
      file_data += conversation.display
    end
    file_path = "#{dir_path}/#{filename}"
    File.open(file_path, 'w') do |f|
      f.write file_data
    end
    puts "文件已经导出至当前目录下exports/#{filename}"
  end
end
