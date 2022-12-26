class User < ApplicationRecord
    has_many :user_groups, dependent: :destroy
    
    has_many :groups, through: :user_groups
    has_one :playlist, as: :ownable, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :music_playlists

    after_create UserCallbacks

    def self.create_user!(name:)
        User.create!(name: name)
    end

    def delete_user!
        self.destroy
    end

    def change_name!(name:)
        self.name = name
        self.save
    end
end
