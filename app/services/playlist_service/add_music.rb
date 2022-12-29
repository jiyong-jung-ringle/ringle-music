module PlaylistService
    class AddMusic < ApplicationService

        def initialize(current_user, playlist, music_ids)
            @current_user = current_user
            @playlist = playlist
            @music_ids = music_ids
        end

        def call
            do_action
            return @success
        end

        private
        def do_action
            musics = Music.where(id: @music_ids)
            if musics.exists?
                append_music_ids = @playlist.append_musics!(user:@current_user, musics: musics)
                @success = {}
                @music_ids.map {|music_id|
                    @success.merge!("#{music_id}": append_music_ids.include?(music_id))
                }
            else
                @success = false
            end
        end

    end

end