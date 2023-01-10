module FeedService
  class MusicsGetter < ApplicationService
    def initialize(current_user, keyword, filter, page_number, limit)
      @current_user = current_user
      @keyword = keyword
      @filter = filter
      @limit = limit
      @page_number = page_number
    end

    def call
      get_order
      get_musics
    end

      private
        def get_order
          @musics_ordered = SearchkickModelGetter.call(Music, @keyword, @filter,
          [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT],
          [:song_name, :artist_name, :album_name],
          @limit, @page_number)
        end

        def get_musics
          {
              total_musics_count: @musics_ordered[:total],
              musics: @musics_ordered[:model]
          }
        end
  end
end
