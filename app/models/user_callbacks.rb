class UserCallbacks

    def self.after_create(user)
        Playlist.create!(ownable: user)
    end

end