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
            get_total
            get_users
            return {
                total_users_count: @total,
                users: @users_result.as_json({
                    only: [
                        :user_id,
                        :name,
                        :joined_at,
                    ]
                })
            }
        end

        private
        def get_group_users
            @model = @group.user_groups.joins(:user)
            .select("#{User.table_name}.*, #{UserGroup.table_name}.created_at AS joined_at, #{UserGroup.table_name}.user_id")
        end

        def get_order
            @users_ordered = OrderedModelGetter.call(@model, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::EXACT], [:name])
        end

        def get_total
            @total = @group.users_count
        end

        def get_users
            @users_result = (@users_ordered.
                offset(@limit*@offset).limit(@limit))
        end
    
    end
end