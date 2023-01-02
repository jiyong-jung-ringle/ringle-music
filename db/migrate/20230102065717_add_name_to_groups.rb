class AddNameToGroups < ActiveRecord::Migration[7.0]
  def change
    add_index :groups, [:name], name: 'group_name', type: :fulltext
  end
end
