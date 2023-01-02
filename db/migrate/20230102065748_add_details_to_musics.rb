class AddDetailsToMusics < ActiveRecord::Migration[7.0]
  def change
    add_index :musics, [:song_name, :artist_name, :album_name], name: 'music_description', type: :fulltext
  end
end
