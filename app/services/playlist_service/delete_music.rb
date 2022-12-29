module PlaylistService
    class DeleteMusic < ApplicationService

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
            unless deleted_music_ids = @playlist.delete_musics!(music_ids: @music_ids)
                @success = false
            else
                @success = {}
                @music_ids.map {|music_id|
                    @success.merge!("#{music_id}": deleted_music_ids.include?(music_id))
                }
            end
        end

    end

end