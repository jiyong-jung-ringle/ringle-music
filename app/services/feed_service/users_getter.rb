module FeedService
    class UsersGetter < ApplicationService

        def initialize(keyword, filter, page_number, limit)
            @keyword = keyword
            @filter = filter
            @limit = limit
            @page_number = page_number
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
                offset(@limit*@page_number).limit(@limit))
            {
                total_users_count: User.count,
                users: users_result
            }
        end
        
    end
end