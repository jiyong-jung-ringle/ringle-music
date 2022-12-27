class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.belongs_to :user
      t.references :likable, polymorphic: true
      t.timestamps
    end
  end
end
