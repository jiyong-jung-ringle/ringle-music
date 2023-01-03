class User < ApplicationRecord
    has_many :user_groups, dependent: :destroy
    
    has_many :groups, through: :user_groups
    has_one :playlist, as: :ownable, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :music_playlists
    
    validates_uniqueness_of :email
    validates :name, :email, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 
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
        begin
            self.name = name
            self.save!
            true
        rescue => e
            false
        end
    end

    def change_password!(password:)
        return false if password=="" || self.authenticate(password)
        begin
            self.password = password
            self.save!
            true
        rescue => e
            false
        end 
    end
end
