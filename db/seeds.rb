# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'faker'

user_count = 10
music_count = 10
group_count = 3
users_per_group = (3..5).to_a
musics_per_playlist = (2..6).to_a
like_musics_per_user = (1..4).to_a
like_playlists_per_user = (0..3).to_a

users = User.all
users.map { |user| user.destroy }

groups = Group.all
groups.map { |group| group.destroy }

musics = Music.all
musics.map { |music| music.destroy }

user_count.times { User.create!(name: Faker::Name.name) }
1.upto(music_count) { |i|
    Music.create!(song_name: "Music #{i}", artist_name: Faker::Artist.name, album_name: Faker::Music.album) 
}

users = User.all
group_count.times {
    group=Group.create!(name: Faker::FunnyName.name)
    users_shuffled = users.shuffle[0..users_per_group.sample-1]
    group.update(users: users_shuffled)
}

musics = Music.all
playlists = Playlist.all
playlists.map { |playlist|
    musics_shuffled = musics.shuffle[0..musics_per_playlist.sample-1]
    playlist.update!(musics: musics_shuffled)
}