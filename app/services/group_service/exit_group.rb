module GroupService
    class ExitGroup < ApplicationService

        def initialize(current_user, group, user_ids)
            @current_user = current_user
            @group = group
            @user_ids = user_ids.include?(current_user.id) ? user_ids : user_ids << current_user.id
        end

        def call
            do_action
        end
        
        private
        def do_action
            unless deleted_user_ids = @group.delete_users!(user_ids: @user_ids)
                false
            else
                success = {}
                @user_ids.map {|user_id|
                    success.merge!("#{user_id}": deleted_user_ids.include?(user_id))
                }
                success
            end
        end

    end

end