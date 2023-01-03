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
            get_users
        end

        private

        def get_order
            @users_ordered = OrderedModelGetter.call(User.select("#{User.table_name}.*"), @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::EXACT], [:name])
        end

        def get_users
            users_result = (@users_ordered.
                offset(@limit*@offset).limit(@limit))
            {
                total_users_count: User.count,
                users: users_result.as_json({
                    only: [
                        :id,
                        :name,
                        :created_at,
                    ]
                })
            }
        end
        
    end
end