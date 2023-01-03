module FeedService
    class PlaylistsGetter < ApplicationService

        def initialize(current_user, filter, offset, limit)
            @current_user = current_user
            @filter = filter
            @limit = limit
            @offset = offset
        end

        def call
            get_order
            get_total
            get_playlists
            get_liked_playlists
            return {
                total_playlists_count: @total,
                playlists: @playlists_result.includes(:ownable).as_json({
                    only: [
                        :id,
                        :likes_count,
                        :musics_count,
                        :ownable_type,
                    ],
                    include: { 
                        ownable: {
                            only: [
                                :id, 
                                :name,
                                :users_count,
                            ] 
                        } 
                    }
                }).map { |json| 
                    @like_service.call(json, json["id"])
                }
            }
        end

        private
        def get_order
            @playlists_ordered = OrderedModelGetter.call(Playlist, nil, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR], [])
        end

        def get_total
            @total = Playlist.count
        end

        def get_playlists
            @playlists_result = (@playlists_ordered.
                offset(@limit*@offset).limit(@limit))
        end

        def get_liked_playlists
            ids = @playlists_result.as_json.map{|v| v["id"]}
            @like_service = VirtualColumnService::IsLiked.new(@current_user, Playlist, ids)
        end
    
    end
end