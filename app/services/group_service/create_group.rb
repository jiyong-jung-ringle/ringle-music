module GroupService
    class CreateGroup < ApplicationService

        def initialize(current_user, name, user_ids)
            @current_user = current_user
            @name = name
            @user_ids = user_ids.include?(current_user.id) ? user_ids : user_ids << current_user.id
        end

        def call
            do_action
        end
        
        private
        def do_action
            users = User.where(id: @user_ids)
            if users.exists?
                return false unless group = Group.create_group!(name: @name, users:users)
                success_users = {}
                user_ids = users.ids
                @user_ids.map {|user_id|
                    success_users.merge!("#{user_id}": user_ids.include?(user_id))
                }
                {group_id: group.id, playlist_id: group.playlist.id,  success_users: success_users}
            else
                nil
            end
        end

    end

end