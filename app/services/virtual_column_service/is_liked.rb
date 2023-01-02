module VirtualColumnService
    class IsLiked < ApplicationService
        def initialize(current_user, model, ids)
            @likes = ModelPreload.new(Like, {likable_type: model.to_s, likable_id: ids, user_id: current_user.id})
        end

        def call(json, id)
            return json.merge!(is_liked: @likes.call(likable_id: id) ? true: false)
        end
    end

end