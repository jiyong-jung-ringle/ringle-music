module FeedService
  class LikeMusicsGetter < ApplicationService
    def initialize(user, keyword, filter, page_number, limit)
      @keyword = keyword
      @filter = filter
      @limit = limit
      @page_number = page_number
      @user = user
      @model = Music
    end

    def call
      get_join_indicator
      get_liked_musics
      get_order
      get_musics
    end

      private
        def get_join_indicator
          @likes_name = Like.table_name
          join_condition = "`#{@likes_name}`.likable_type = '#{@model}' AND `#{@likes_name}`.likable_id = `#{@model.table_name}`.id"
          @join_indicator = "INNER JOIN `#{@model.table_name}` ON (#{join_condition})"
        end
        def get_liked_musics
          @musics = @user.likes.joins(@join_indicator)
          .select("#{@model.table_name}.*, #{@likes_name}.created_at AS liked_at")
        end

        def get_order
          @musics_ordered = OrderedModelGetter.call(@musics, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT], [:song_name, :artist_name, :album_name])
        end

        def get_musics
          musics_result = (@musics_ordered.
              offset(@limit * @page_number).limit(@limit))

          {
              total_musics_count: @user.likes.where(likable_type: @model.to_s).count,
              musics: musics_result
          }
        end
  end
end
