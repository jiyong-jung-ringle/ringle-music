class ChnageDetailsInMusicPlaylists < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :music_playlists, :users
    change_column_null :music_playlists, :music_id, true
    change_column_null :music_playlists, :playlist_id, true
  end
end
