class User < ApplicationRecord
    has_many :user_groups, dependent: :destroy
    
    has_many :groups, through: :user_groups
    has_many :playlists, as: :ownable, dependent: :destroy
    has_many :likes, dependent: :destroy

    after_create UserCallbacks
end
