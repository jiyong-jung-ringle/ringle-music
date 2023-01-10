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
user_count = 300
music_count = 1000000
group_count = 30
users_per_group = (3..20).to_a
musics_per_playlist = (30..100).to_a
likes_per_user = (0..50).to_a

## Reset database
puts "Reset Users..."
User.destroy_all
puts "Reset Groups..."
Group.destroy_all
puts "Reset Musics..."
Music.destroy_all

## Make Users
puts "Making #{user_count} Users..."
(1..user_count).each do |i|
    musics = []
    User.create_user!(name: Faker::Name.name, email: "user_#{i}@gmail.com", password: "ringle#{i}")
end

## Make Musics
puts "Making #{music_count} Musics..."
(1..music_count).each_slice(1000).each do |batch|
    musics = []
    batch.each do |i|
        musics << {song_name: "Music #{i}", artist_name: Faker::Artist.name, album_name: Faker::Music.album}
    end
    Music.insert_all(musics)
end
sample_music_file =  Rails.root.join("config", "musics", "music.csv")
music_csvs = CSV.parse(File.read(sample_music_file), :headers=>true)
music_csvs.each_slice(1000).each do |batch|
    musics = []
    batch.each do |music_csv|
        music_csv = music_csv.to_hash
        musics << {song_name: music_csv["title"], artist_name: music_csv["artist_name"], album_name: music_csv["album_name"]}
    end
    Music.insert_all(musics)
end

## Make Groups
puts "Making #{group_count} Groups..."
users = User.all
group_count.times {
    users_shuffled = users.shuffle[0..users_per_group.sample-1]
    Group.create_group!(name: "#{Faker::FunnyName.name} Group", users: users_shuffled)
}

## Append Musics in Playlists
puts "Appending musics in Playlist..."
musics = Music.all
playlists = Playlist.all
playlists.map { |playlist|
    user = playlist.ownable_type == User.to_s ? playlist.ownable : playlist.ownable.users.first
    musics_shuffled = musics.order("RAND()").limit(musics_per_playlist.sample)
    playlist.append_musics!(user: user, musics: musics_shuffled)
}

## Make Likes
puts "Making likes..."
likable = musics + playlists
users.map { |user|
    likes_per_user.sample.times {
        Like.toggle_like!(user: user, likable: likable.sample)
    }
}

puts "Reindexing #{music_count} Musics..."
Music.reindex
puts "Completed"