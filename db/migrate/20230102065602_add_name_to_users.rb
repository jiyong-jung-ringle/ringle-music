class AddNameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, [:name], name: 'user_name', type: :fulltext
  end
end
