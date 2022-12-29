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
            get_liked_musics
            get_order
            get_total
            get_musics
            return {
                total_musics_count: @total,
                musics: @musics_result.as_json({
                    only: [
                        :id,
                        :song_name,
                        :artist_name,
                        :album_name,
                        :likes_count,
                        :is_liked,
                    ]
                }).map {|json| json.merge!(is_liked: json["is_liked"]==1 ? true: false)}
            }
        end

        private
        def get_liked_musics
            @musics_liked = VirtualColumnService::IsLiked.call(@current_user, Music, Music)
        end
        def get_order
            @musics_ordered = OrderedModelGetter.call(@musics_liked, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR, OrderFilterStatus::EXACT], [:song_name, :artist_name, :album_name])
        end

        def get_total
            @total = Music.count()
        end

        def get_musics
            @musics_result = (@musics_ordered.
                offset(@limit*@offset).limit(@limit))
        end
    
    end
end