module GroupService
  class JoinGroup < ApplicationService
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
          users = User.where(id: (@user_ids - @group.users.ids))
          if users.exists?
            append_user_ids = @group.append_users!(users: users).ids
            success = {}
            user_ids = users.ids
            @user_ids.map { |user_id|
              success.merge!("#{user_id}": append_user_ids.include?(user_id))
            }
            success
          else
            false
          end
        end
  end
end
