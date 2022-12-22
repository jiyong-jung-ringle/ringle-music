class Music < ApplicationRecord
    has_many :music_playlists, dependent: :destroy
    
    has_many :playlists, through: :music_playlists
    has_many :likes, as: :likable, dependent: :destroy 
end
