class AddParentId < ActiveRecord::Migration[6.1]
  def change
    add_column :conversations, :parent_id, :string
  end
end
