class UserCallbacks

    def self.after_create(user)
        Playlist.create!(name: "#{user.name}님의 플레이리스트", ownable: user)
    end

end