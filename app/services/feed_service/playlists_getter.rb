module FeedService
  class PlaylistsGetter < ApplicationService
    def initialize(current_user, filter, page_number, limit)
      @current_user = current_user
      @filter = filter
      @limit = limit
      @page_number = page_number
    end

    def call
      get_order
      get_playlists
    end

      private
        def get_order
          @playlists_ordered = OrderedModelGetter.call(Playlist, nil, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR], [])
        end

        def get_playlists
          playlists_result = (@playlists_ordered.
              offset(@limit * @page_number).limit(@limit))
          {
              total_playlists_count: Playlist.count,
              playlists: playlists_result.includes(:ownable)
          }
        end
  end
end
