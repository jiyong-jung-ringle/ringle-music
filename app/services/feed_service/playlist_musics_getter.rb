module FeedService
    class PlaylistMusicsGetter < ApplicationService

        def initialize(current_user, playlist, keyword, filter, page_number, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @page_number = page_number
            @playlist = playlist
        end

        def call
            get_playlist_musics
            get_order
            get_musics
        end

        private
        def get_playlist_musics
            @model = @playlist.music_playlists.joins(:music)
            .select("#{Music.table_name}.*, #{MusicPlaylist.table_name}.user_id, #{MusicPlaylist.table_name}.id AS music_playlist_id, 
                #{MusicPlaylist.table_name}.created_at AS added_at")
        end
        def get_order
            @musics_ordered = OrderedModelGetter.call(@model, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT], [:song_name, :artist_name, :album_name])
        end

        def get_musics
            musics_result = (@musics_ordered.
                offset(@limit*@page_number).limit(@limit))
            ids = musics_result.as_json.map{|v| v["id"]}
            like_service = VirtualColumnService::IsLiked.new(@current_user, Music, ids)
            {
                total_musics_count: @playlist.musics_count,
                musics: musics_result.includes(:user).as_json({
                    only: [
                        :id,
                        :music_playlist_id,
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
                    like_service.call(json, json["id"])
                }
            }
        end
    end
end