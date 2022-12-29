module FeedService
    class PlaylistMusicsGetter < ApplicationService

        def initialize(current_user, playlist, keyword, filter, offset, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @offset = offset
            @playlist = playlist
        end

        def call
            get_playlist_musics
            get_liked_musics
            get_order
            get_total
            get_musics
            return {
                total_musics_count: @total,
                musics: @musics_result.includes(:user).as_json({
                    only: [
                        :id,
                        :music_id,
                        :song_name,
                        :artist_name,
                        :album_name,
                        :likes_count,
                        :is_liked,
                        :added_at,
                    ],
                    include: { 
                        user: {
                            only: [
                                :id, 
                                :name,
                            ] 
                        } 
                    }
                }).map {|json| json.merge!(is_liked: json["is_liked"]==1 ? true: false)}
            }
        end

        private
        def get_playlist_musics
            @model = @playlist.music_playlists.joins(:music)
            .select("#{Music.table_name}.*, #{MusicPlaylist.table_name}.created_at AS added_at")
        end

        def get_liked_musics
            @musics_liked = VirtualColumnService::IsLiked.call(@current_user, @model, Music)
        end
        def get_order
            @musics_ordered = OrderedModelGetter.call(@musics_liked, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT], [:song_name, :artist_name, :album_name])
        end

        def get_total
            @total = @playlist.musics_count
        end

        def get_musics
            @musics_result = (@musics_ordered.
                offset(@limit*@offset).limit(@limit))
        end
    
    end
end