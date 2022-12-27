class CreateMusics < ActiveRecord::Migration[7.0]
  def change
    create_table :musics do |t|
      t.string :song_name
      t.string :artist_name
      t.string :album_name
      t.integer :likes_count, default: 0
      t.timestamps
    end
  end
end
