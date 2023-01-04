module FeedService
    class LikePlaylistsGetter < ApplicationService

        def initialize(user, filter, page_number, limit)
            @filter = filter
            @limit = limit
            @page_number = page_number
            @user = user
            @model = Playlist
        end

        def call
            get_liked_playlists
            get_order
            get_playlists
        end

        private
        def get_liked_playlists
            @playlist_ids = @user.likes.where(likable_type: @model.to_s).pluck(:likable_id)
            @playlists = Playlist.where(id: @playlist_ids)
        end

        def get_order
            @playlists_ordered = OrderedModelGetter.call(@playlists, "", @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR], [])
        end

        def get_playlists
            playlists_result = (@playlists_ordered.
                offset(@limit*@page_number).limit(@limit))
            {
                total_playlists_count: @playlist_ids.length,
                playlists: playlists_result.includes(:ownable)
            }
        end
        
    end
end