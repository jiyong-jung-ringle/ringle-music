class MusicPlaylist < ApplicationRecord
    belongs_to :music
    belongs_to :playlist, counter_cache: :musics_count
    belongs_to :user
end
