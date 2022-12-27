module Feed
    class MusicGetter < ApplicationService

        def initialize(current_user, keyword, filter, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
        end

        def call
            get_liked
            get_order
            get_total
            get_musics
            return {
                total_music: @total,
                musics: @musics.as_json({
                    only: [
                        :id,
                        :song_name,
                        :artist_name,
                        :album_name,
                        :likes_count,
                        :is_liked,
                    ]
                })
            }
        end

        private
        def get_liked
            @musics_liked = VirtualColumn::IsLiked.call(@current_user, Music)
        end
        def get_order
            @musics_ordered = OrderedModelGetter.call(@musics_liked, @filter, @keyword, [:song_name, :artist_name, :album_name])
        end

        def get_total
            @total = Music.count()
        end

        def get_musics
            @musics = (@musics_ordered
                .limit(@limit))
        end
    end

end