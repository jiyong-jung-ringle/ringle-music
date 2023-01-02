module VirtualColumnService
    class IsJoined < ApplicationService
        def initialize(current_user, group_ids)
            @joins = ModelPreload.new(UserGroup, {group_id: group_ids, user_id: current_user.id})
        end

        def call(json, id)
            return json.merge!(is_joined: @joins.call(group_id: id) ? true: false)
        end
    end
end