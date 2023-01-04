module FeedService
    class LikesGetter < ApplicationService

        def initialize(current_user, likable, keyword, filter, page_number, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @page_number = page_number
            @likable = likable
        end

        def call
            get_liked_users
            get_order
            get_users
        end

        private
        def get_liked_users
            @users = @likable.likes.joins(:user)
            .select("#{User.table_name}.*, #{Like.table_name}.created_at AS liked_at")
        end

        def get_order
            @users_ordered = OrderedModelGetter.call(@users, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::EXACT], [:name])
        end

        def get_users
            users_result = (@users_ordered.
                offset(@limit*@page_number).limit(@limit))
            {
                total_likes_count: @likable.likes_count,
                like_users: users_result.as_json({
                    only: [
                        :id,
                        :name,
                        :liked_at,
                    ]
                })
            }
        end
        
    end
end