module FeedService
    class GroupUsersGetter < ApplicationService

        def initialize(current_user, group, keyword, filter, offset, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @offset = offset
            @group = group
        end

        def call
            get_group_users
            get_order
            get_users
        end

        private
        def get_group_users
            @model = @group.user_groups.joins(:user)
            .select("#{User.table_name}.*, #{UserGroup.table_name}.created_at AS joined_at")
        end

        def get_order
            @users_ordered = OrderedModelGetter.call(@model, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::EXACT], [:name])
        end

        def get_users
            users_result = (@users_ordered.
                offset(@limit*@offset).limit(@limit))
            {
                total_users_count: @group.users_count,
                users: users_result.as_json({
                    only: [
                        :id,
                        :name,
                        :joined_at,
                    ]
                })
            }
        end
    
    end
end