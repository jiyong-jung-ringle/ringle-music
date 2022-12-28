module FeedService
    class LikeListGetter < ApplicationService

        def initialize(current_user, likable, keyword, filter, offset, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @offset = offset
            @likable = likable
        end

        def call
            get_liked_users
            get_order
            get_total
            get_users
            return {
                total_likes_count: @total,
                like_users: @users_result.as_json({
                    only: [
                        :user_id,
                        :name,
                        :created_at
                    ]
                })
            }
        end

        private
        def get_liked_users
            @users = @likable.likes.joins(:user).select(:id, :created_at, :name, :user_id)
        end

        def get_order
            @users_ordered = OrderedModelGetter.call(@users, @keyword, @filter, [:name])
        end

        def get_total
            @total = @likable.likes_count
        end

        def get_users
            @users_result = (@users_ordered.
                offset(@limit*@offset).limit(@limit))
        end
        
    end
end