class CreatePlaylists < ActiveRecord::Migration[7.0]
  def change
    create_table :playlists do |t|
      t.integer :likes_count, default: 0
      t.references :ownable, polymorphic: true
      t.integer :musics_count, default: 0
      t.timestamps
    end
  end
end