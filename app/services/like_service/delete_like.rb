module LikeService
    class DeleteLike < ApplicationService

        def initialize(current_user, likable)
            @current_user = current_user
            @likable = likable
        end

        def call
            do_action
        end

        private
        def do_action
            Like.destroy_like!(user: @current_user, likable: @likable)
        end

    end

end