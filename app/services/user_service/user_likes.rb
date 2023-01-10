module UserService
  class UserLikes < ApplicationService
    def initialize(model, current_user)
      @current_user_likes = current_user.likes.where(likable_type: model.to_s).pluck(:likable_id).freeze
    end

    def call(id)
      @current_user_likes.include?(id)
    end
  end
end
