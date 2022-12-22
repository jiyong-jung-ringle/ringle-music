class GroupCallbacks

    def self.after_create(group)
        Playlist.create!(name: "#{group.name} 그룹의 플레이리스트", ownable: group)
    end

end