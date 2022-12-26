class GroupCallbacks

    def self.after_create(group)
        Playlist.create!(ownable: group)
    end

end