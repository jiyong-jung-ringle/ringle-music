module FeedService
    class PlaylistsGetter < ApplicationService

        def initialize(current_user, model, filter, offset, limit)
            @current_user = current_user
            @filter = filter
            @limit = limit
            @offset = offset
            @model = model
        end

        def call
            get_liked_playlists
            get_order
            get_total
            get_playlists
            return {
                total_playlists_count: @total,
                playlists: @playlists_result.includes(:ownable).as_json({
                    only: [
                        :id,
                        :likes_count,
                        :is_liked,
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
                })
            }
        end

        private
        def get_liked_playlists
            @playlists_liked = VirtualColumnService::IsLiked.call(@current_user, @model)
        end
        def get_order
            @playlists_ordered = OrderedModelGetter.call(@playlists_liked, nil, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR], [])
        end

        def get_total
            @total = @model.count()
        end

        def get_playlists
            @playlists_result = (@playlists_ordered.
                offset(@limit*@offset).limit(@limit))
        end
    
    end
end