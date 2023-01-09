class Playlist < ApplicationRecord
  has_many :music_playlists, dependent: :destroy
  has_many :musics, through: :music_playlists
  has_many :likes, as: :likable, dependent: :destroy
  belongs_to :ownable, polymorphic: true

  MAXIMUM_MUSIC_COUNTS = 100

  def append_musics!(user:, musics:)
    Playlist.transaction do
      self.lock!
      MusicPlaylist.create!(
            musics.last(MAXIMUM_MUSIC_COUNTS).map { |music|
                  { music: music, playlist: self, user: user }
                }
          )
      self.delete_old_musics!
      musics.ids
        rescue => e
          return []
    end
  end

  def append_music!(user:, music:)
    self.append_musics!(user: user, musics: [music])
  end

  def delete_musics!(music_ids:)
    Playlist.transaction do
      self.lock!
      music_playlists = self.music_playlists.where(id: music_ids)
      music_playlist_ids = music_playlists.ids
      return false unless music_playlists.exists?
      music_playlists.destroy_all
      music_playlist_ids
    rescue => e
      return []
    end
  end

  def delete_music!(user:, music_id:)
    self.delete_musics!(user: user, music_ids: [music_id])
  end

  def delete_old_musics!
    playlist_count = self.musics_count
    if playlist_count > MAXIMUM_MUSIC_COUNTS
      target_musics = self.music_playlists.order(created_at: :asc).limit(playlist_count - MAXIMUM_MUSIC_COUNTS)
      target_musics.destroy_all
    end
  end

  def include_user?(user:)
    self.ownable_type == User.to_s ? self.ownable == user : self.ownable.include_user?(user: user)
  end
end
