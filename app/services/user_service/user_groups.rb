module UserService
    class UserGroups < ApplicationService
        def initialize(current_user)
            @current_user_groups = current_user.groups.ids
        end

        def call(id)
            @current_user_groups.include?(id)
        end
    end
end