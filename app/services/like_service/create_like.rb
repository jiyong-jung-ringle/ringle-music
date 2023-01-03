module LikeService
    class CreateLike < ApplicationService

        def initialize(current_user, likable)
            @current_user = current_user
            @likable = likable
        end

        def call
            do_action
        end

        private
        def do_action
            Like.create_like!(user: @current_user, likable: @likable)
        end

    end

end