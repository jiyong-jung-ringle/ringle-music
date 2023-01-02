module FeedService
    class LikeMusicsGetter < ApplicationService

        def initialize(user, keyword, filter, offset, limit)
            @keyword = keyword
            @filter = filter
            @limit = limit
            @offset = offset
            @user = user
            @model = Music
        end

        def call
            get_join_indicator
            get_liked_musics
            get_order
            get_total
            get_musics
            return {
                total_musics_count: @total,
                musics: @musics_result.as_json({
                    only: [
                        :music_id,
                        :song_name,
                        :artist_name,
                        :album_name,
                        :likes_count,
                        :liked_at,
                    ]
                })
            }
        end

        private
        def get_join_indicator
            @likes_name = Like.table_name
            join_condition = "`#{@likes_name}`.likable_type = '#{@model.to_s}' AND `#{@likes_name}`.likable_id = `#{@model.table_name}`.id"
            @join_indicator = "INNER JOIN `#{@model.table_name}` ON (#{join_condition})"
        end
        def get_liked_musics
            @musics = @user.likes.joins(@join_indicator)
            .select("#{@model.table_name}.*, #{@likes_name}.created_at AS liked_at, #{@model.table_name}.id AS music_id")
        end

        def get_order
            @musics_ordered = OrderedModelGetter.call(@musics, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT], [:song_name, :artist_name, :album_name])
        end

        def get_total
            @total = @user.likes.where(likable_type: @model.to_s).count()
        end

        def get_musics
            @musics_result = (@musics_ordered.
                offset(@limit*@offset).limit(@limit))
        end
        
    end
end