class AddReferencesToUsersInLikes < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :likes, :users
  end
end
