module FeedService
    class MusicsGetter < ApplicationService

        def initialize(current_user, keyword, filter, offset, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @offset = offset
        end

        def call
            get_order
            get_total
            get_musics
            get_liked_service
            return {
                total_musics_count: @total,
                musics: @musics_result.as_json({
                    only: [
                        :id,
                        :song_name,
                        :artist_name,
                        :album_name,
                        :likes_count,
                        :score,
                    ]
                }).map { |json| 
                    @like_service.call(json, json["id"])
                }
            }
        end

        private
        def get_order
            @musics_ordered = OrderedModelGetter.call(Music, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT], [:song_name, :artist_name, :album_name])
        end

        def get_total
            @total = Music.count()
        end

        def get_musics
            @musics_result = (@musics_ordered.
                offset(@limit*@offset).limit(@limit))
        end

        def get_liked_service
            ids = @musics_result.as_json.map{|v| v["id"]}
            @like_service = VirtualColumnService::IsLiked.new(@current_user, Music, ids)
        end
    
    end
end