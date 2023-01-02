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
            get_order
            get_total
            get_musics
            get_liked_musics
            return {
                total_musics_count: @total,
                musics: @musics_result.includes(:user).as_json({
                    only: [
                        :id,
                        :song_name,
                        :artist_name,
                        :album_name,
                        :likes_count,
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
                }).map {|json| 
                    @like_service.call(json, json["id"])
                }
            }
        end

        private
        def get_playlist_musics
            @model = @playlist.music_playlists.joins(:music)
            .select("#{Music.table_name}.*, #{MusicPlaylist.table_name}.user_id, 
                #{MusicPlaylist.table_name}.created_at AS added_at")
        end
        def get_order
            @musics_ordered = OrderedModelGetter.call(@model, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT], [:song_name, :artist_name, :album_name])
        end

        def get_total
            @total = @playlist.musics_count
        end

        def get_musics
            @musics_result = (@musics_ordered.
                offset(@limit*@offset).limit(@limit))
        end

        def get_liked_musics
            @like_service = VirtualColumnService::IsLiked.new(@current_user, Music, @musics_result.pluck(:music_id))
        end
    end
end