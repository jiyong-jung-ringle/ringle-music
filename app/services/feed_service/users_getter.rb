module FeedService
    class UsersGetter < ApplicationService

        def initialize(keyword, filter, offset, limit)
            @keyword = keyword
            @filter = filter
            @limit = limit
            @offset = offset
        end

        def call
            get_order
            get_total
            get_users
            return {
                total_users_count: @total,
                users: @users_result.as_json({
                    only: [
                        :id,
                        :name,
                        :created_at,
                    ]
                })
            }
        end

        private

        def get_order
            @users_ordered = OrderedModelGetter.call(User, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::EXACT], [:name])
        end

        def get_total
            @total = User.count
        end

        def get_users
            @users_result = (@users_ordered.
                offset(@limit*@offset).limit(@limit))
        end
        
    end
end