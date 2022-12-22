class Playlist < ApplicationRecord
    has_many :music_playlists, dependent: :destroy

    has_many :musics, through: :music_playlists
    has_many :likes, as: :likable, dependent: :destroy 
    belongs_to :ownable, polymorphic: true

    after_update PlaylistCallbacks
end
