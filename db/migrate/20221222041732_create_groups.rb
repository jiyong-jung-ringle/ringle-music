class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :users_count, default: 0
      t.timestamps
    end
  end
end
