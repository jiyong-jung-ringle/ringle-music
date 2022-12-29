module FeedService
    class GroupsGetter < ApplicationService

        def initialize(current_user, keyword, filter, offset, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @offset = offset
        end

        def call
            get_joined_groups
            get_order
            get_total
            get_groups
            return {
                total_groups_count: @total,
                groups: @groups_result.as_json({
                    only: [
                        :id,
                        :name,
                        :users_count,
                        :is_joined,
                    ]
                })
            }
        end

        private
        def get_joined_groups
            @groups_joined = VirtualColumnService::IsJoined.call(@current_user, Group)
        end
        def get_order
            @groups_ordered = OrderedModelGetter.call(@groups_joined, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::EXACT], [:name])
        end

        def get_total
            @total = Group.count()
        end

        def get_groups
            @groups_result = (@groups_ordered.
                offset(@limit*@offset).limit(@limit))
        end
    
    end
end