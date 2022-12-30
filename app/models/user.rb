class User < ApplicationRecord
    has_many :user_groups, dependent: :destroy
    
    has_many :groups, through: :user_groups
    has_one :playlist, as: :ownable, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :music_playlists
    
    validates_uniqueness_of :email
    has_secure_password

    after_create UserCallbacks

    def self.create_user!(name:, email:, password:)
        begin
            User.create!(name: name, email: email, password: password)
        rescue => e
            nil
        end
    end

    def delete_user!
        self.destroy
    end

    def change_name!(name:)
        self.name = name
        self.save
    end

    def change_password!(password:)
        self.password = password
        self.save
    end
end
