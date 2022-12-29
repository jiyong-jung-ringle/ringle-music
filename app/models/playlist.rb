class Playlist < ApplicationRecord
    has_many :music_playlists, dependent: :destroy
    has_many :musics, through: :music_playlists
    has_many :likes, as: :likable, dependent: :destroy 
    belongs_to :ownable, polymorphic: true

    @@maximum_musics_count = 100

    def append_musics!(user:, musics:)
        Playlist.transaction do
            MusicPlaylist.create!(
                musics.map { |music|
                    {music: music, playlist: self, user: user}
                    }
                )
            self.delete_old_musics!
        end
        return musics.ids
    end

    def append_music!(user:, music:)
        return self.append_musics!(user: user, musics: [music])
    end

    def delete_musics!(music_ids:)
        music_playlists = self.music_playlists.where(id: music_ids)
        music_playlist_ids = music_playlists.ids
        return false unless music_playlists.exists?
        Playlist.transaction do
            music_playlists.destroy_all
        end
        return music_playlist_ids
    end

    def delete_music!(user:, music_id:)
        return self.delete_musics!(user: user, music_ids: [music_id])
    end

    def delete_old_musics!
        playlist_count = self.musics_count
        if playlist_count > @@maximum_musics_count
            target_musics = self.music_playlists.order(created_at: :asc).limit(playlist_count - @@maximum_musics_count)
            target_musics.destroy_all
        end
    end

    def include_user?(user:)
        self.ownable_type == User.to_s ? self.ownable == user : self.ownable.include_user?(user: user)
    end
end