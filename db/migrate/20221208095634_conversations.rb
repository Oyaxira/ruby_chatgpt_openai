class Conversations < ActiveRecord::Migration[6.1]
  def change
    create_table :conversations do |t|
      t.text :prompt
      t.text :answer
      t.string :conversation_id
      t.string :message_id
      t.boolean :is_fav
      t.timestamps
    end
  end
end
