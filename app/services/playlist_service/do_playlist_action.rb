module PlaylistService
    class DoPlaylistAction < ApplicationService

        def initialize(current_user, playlist, music_ids, action)
            @current_user = current_user
            @playlist = playlist
            @music_ids = music_ids
            @action = action
        end

        def call
            do_action
            return @success
        end

        def do_action
            if @action==PlaylistActionStatus::ADD
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
            elsif @action==PlaylistActionStatus::DELETE
                unless deleted_music_ids = @playlist.delete_musics!(music_ids: @music_ids)
                    @success = false
                else
                    @success = {}
                    @music_ids.map {|music_id|
                        @success.merge!("#{music_id}": deleted_music_ids.include?(music_id))
                    }
                end
            else
                @success = false
            end
        end

    end

end