class Music < ApplicationRecord
  has_many :music_playlists, dependent: :destroy

  has_many :playlists, through: :music_playlists
  has_many :likes, as: :likable, dependent: :destroy
  searchkick

  after_create :reindex_music

  def self.reindex_music
    p "call"
    music.reindex
  end

  def self.create_music!(song_name:, artist_name:, album_name:)
    self.lock
    Music.create!(song_name: song_name, artist_name: artist_name, album_name: album_name)
  rescue => e
    nil
  end

  def delete_music!
    self.destroy
  end
end
