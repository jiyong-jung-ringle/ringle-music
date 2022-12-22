class CreateMusicPlaylists < ActiveRecord::Migration[7.0]
  def change
    create_table :music_playlists do |t|
      t.references :music, null: false, foreign_key: true
      t.references :playlist, null: false, foreign_key: true
      t.timestamps
    end
  end
end
