class PlaylistCallbacks

    def self.after_update(playlist)
        playlist_count = playlist.musics.count()
        if playlist_count>100
            target_musics = playlist.music_playlists.order(created_at: :asc)[0..((playlist_count-100)-1)]
            target_musics.map { |music_playlist|
                music_playlist.destroy
            }
        end
    end
end