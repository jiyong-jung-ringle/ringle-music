module Entities
  class MusicBasic < Grape::Entity
    self.hash_access = :to_s

    expose :id, :song_name, :artist_name, :album_name, :likes_count
    expose :user_likes, as: :is_liked
    
    expose :liked_at, if: :with_like

    expose :music_playlist_id, :added_at, if: :in_playlist 
    expose :user, using: User, if: :in_playlist
    
    private
    def initialize(music, option = {})
      @current_user_likes = option[:current_user_likes]
      super(music, option)
    end

    def user_likes
      @current_user_likes.call(object["id"]) ? true : false
    end
  end
end