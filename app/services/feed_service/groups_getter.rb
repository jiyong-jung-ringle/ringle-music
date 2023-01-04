module FeedService
    class GroupsGetter < ApplicationService

        def initialize(current_user, keyword, filter, page_number, limit)
            @current_user = current_user
            @keyword = keyword
            @filter = filter
            @limit = limit
            @page_number = page_number
        end

        def call
            get_order
            get_total
            get_groups
        end

        private
        def get_order
            @groups_ordered = OrderedModelGetter.call(Group, @keyword, @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::EXACT], [:name])
        end

        def get_total
            @total = Group.count
        end

        def get_groups
            groups_result = (@groups_ordered.
                offset(@limit*@page_number).limit(@limit))
            ids = groups_result.as_json.map{|v| v["id"]}
            is_joined_service = VirtualColumnService::IsJoined.new(@current_user, ids)

            {
                total_groups_count: @total,
                groups: groups_result.as_json({
                    only: [
                        :id,
                        :name,
                        :users_count,
                    ]
                }).map { |json| 
                    is_joined_service.call(json, json["id"])
                }
            }
        end    
    end
end