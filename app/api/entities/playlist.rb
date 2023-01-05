module Entities
  class Playlist < Grape::Entity
    self.hash_access = :to_s

    expose :id, :likes_count, :musics_count, :ownable_type
    expose :user_likes, as: :is_liked
    expose :ownable do |playlist, options|
      case playlist.ownable_type
      when User.to_s
        User.represent playlist.ownable
      when Group.to_s
        Group.represent playlist.ownable, options.merge(current_user_groups: @current_user_groups)
      else
        nil
      end
    end
    
    expose :liked_at, if: :with_liked
    
    private
    def initialize(playlist, option = {})
      @current_user_likes = option[:current_user_likes]
      @current_user_groups = option[:current_user_groups]
      super(playlist, option)
    end

    def user_likes
      @current_user_likes.call(object["id"]) ? true : false
    end

  end
end