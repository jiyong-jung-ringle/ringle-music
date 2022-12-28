module LikeService
    class ModifyLike < ApplicationService

        def initialize(current_user, likable, action)
            @current_user = current_user
            @likable = likable
            @action = action
        end

        def call
            do_action
            return @success
        end

        def do_action
            if @action==LikeAction::POST
                Like.create_like!(user: @current_user, likable: @likable) ? @success = true : @success = false
            elsif @action==LikeAction::DELETE
                Like.destroy_like!(user: @current_user, likable: @likable)  ? @success = true : @success = false
            else
                @success = false
            end
        end

    end

end