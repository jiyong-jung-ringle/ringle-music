module LikeService
    class DeleteLike < ApplicationService

        def initialize(current_user, likable)
            @current_user = current_user
            @likable = likable
        end

        def call
            do_action
            return @success
        end

        private
        def do_action
            Like.destroy_like!(user: @current_user, likable: @likable)  ? @success = true : @success = false
        end

    end

end