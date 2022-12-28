# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'faker'


## Parameters
user_count = 10
music_count = 10
group_count = 3
users_per_group = (3..5).to_a
musics_per_playlist = (2..6).to_a
likes_per_user = (0..7).to_a

## Reset database
users = User.all
users.map { |user| user.destroy }

groups = Group.all
groups.map { |group| group.destroy }

musics = Music.all
musics.map { |music| music.destroy }

## Make Users
user_count.times { 
    User.create_user!(name: Faker::Name.name) 
}

## Make Musics
1.upto(music_count) { |i|
    Music.create_music!(song_name: "Music #{i}", artist_name: Faker::Artist.name, album_name: Faker::Music.album) 
}

## Make Groups
users = User.all
group_count.times {
    users_shuffled = users.shuffle[0..users_per_group.sample-1]
    Group.create_group!(name: Faker::FunnyName.name, users: users_shuffled)
}

## Append Musics in Playlists
musics = Music.all
playlists = Playlist.all
playlists.map { |playlist|
    user = playlist.ownable_type == User.to_s ? playlist.ownable : playlist.ownable.users.first
    musics_shuffled = musics.shuffle[0..musics_per_playlist.sample-1]
    playlist.append_musics!(user: user, musics: musics_shuffled)
}

## Make Likes
likable = musics + playlists
users.map { |user|
    likes_per_user.sample.times {
        Like.toggle_like!(user: user, likable: likable.sample)
    }
}