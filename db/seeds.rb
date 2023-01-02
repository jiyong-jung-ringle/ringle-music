# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'faker'
require 'CSV'


## Parameters
user_count = 100
music_count = 1500
group_count = 3
users_per_group = (3..20).to_a
musics_per_playlist = (30..100).to_a
likes_per_user = (0..50).to_a

## Reset database
users = User.all
users.map { |user| user.destroy }

groups = Group.all
groups.map { |group| group.destroy }

musics = Music.all
musics.map { |music| music.destroy }

## Make Users
1.upto(user_count) { |i|
    User.create_user!(name: Faker::Name.name, email: "user_#{i}@gmail.com", password: "ringle#{i}") 
}

## Make Musics
sample_music_file =  Rails.root.join("config", "musics", "music.csv")
music_csvs = CSV.parse(File.read(sample_music_file), :headers=>true)
music_csv_sampled = music_csvs[0..(music_count-1)]
music_csv_sampled.map { |music_csv|
    music_csv = music_csv.to_hash
    Music.create_music!(song_name: music_csv["title"], artist_name: music_csv["artist_name"], album_name: music_csv["album_name"]) 
}

## Make Groups
users = User.all
group_count.times {
    users_shuffled = users.shuffle[0..users_per_group.sample-1]
    Group.create_group!(name: "#{Faker::FunnyName.name} Group", users: users_shuffled)
}

## Append Musics in Playlists
musics = Music.all
playlists = Playlist.all
playlists.map { |playlist|
    user = playlist.ownable_type == User.to_s ? playlist.ownable : playlist.ownable.users.first
    musics_shuffled = musics.order("RAND()").limit(musics_per_playlist.sample)
    playlist.append_musics!(user: user, musics: musics_shuffled)
}

## Make Likes
likable = musics + playlists
users.map { |user|
    likes_per_user.sample.times {
        Like.toggle_like!(user: user, likable: likable.sample)
    }
}

puts "Completed"