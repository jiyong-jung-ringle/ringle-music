module V1
    class PlaylistApi < Grape::API
        resource :playlists do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                optional :page_number, type: Integer, values: { proc: ->(page_number) { page_number.positive? || page_number==0 } }, default: 0
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR], default: FeedService::OrderFilterStatus::POPULAR
            end
            get do
                authenticate!
                playlists = FeedService::PlaylistsGetter.call(current_user, params[:filter], params[:page_number], params[:limit])
                
                present :success, true
                present :total_playlists_count, playlists[:total_playlists_count]
                present :playlists, playlists[:playlists], with: Entities::PlaylistEntity, current_user_likes: current_user_likes(Playlist), current_user_groups: current_user_groups
            end

            route_param :playlist_id, type: Integer do
                params do
                    optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                    optional :page_number, type: Integer, values: { proc: ->(page_number) { page_number.positive? || page_number==0 } }, default: 0
                    optional :keyword, type: String
                    optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                end
                get do
                    authenticate!
                    error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    musics = FeedService::PlaylistMusicsGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:page_number], params[:limit])
                    present :success, true
                    present :total_musics_count, musics[:total_musics_count]
                    present :musics, musics[:musics], with: Entities::MusicEntity, in_playlist: true, current_user_likes: current_user_likes(Music)
                end
                params do
                    requires :music_ids, type: Array[Integer]
                end
                post do
                    authenticate!
                    error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    error!("You cannot modify this playlist") unless playlist.include_user?(user: current_user)
                    error!("Cannot add musics") unless result = PlaylistService::AddMusic.call(current_user, playlist, params[:music_ids])
                    
                    present :success, true
                end
                params do
                    requires :music_ids, type: Array[Integer]
                end
                delete do
                    authenticate!
                    error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    error!("You cannot modify this playlist") unless playlist.include_user?(user: current_user)
                    error!("Cannot delete musics") unless result = PlaylistService::DeleteMusic.call(current_user, playlist, params[:music_ids])
                    
                    present :success, true
                end

                resource :likes do
                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :page_number, type: Integer, values: { proc: ->(page_number) { page_number.positive? || page_number==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        likes = FeedService::LikesGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:page_number], params[:limit])

                        present :success, true
                        present :total_likes_count, likes[:total_likes_count]
                        present :like_users, likes[:like_users], with: Entities::UserEntity, with_like: true
                    end

                    post do
                        authenticate!
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error!("Already liked") unless LikeService::CreateLike.call(current_user, playlist)
                        
                        present :success, true
                    end

                    delete do
                        authenticate!
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error!("Already unliked") unless LikeService::DeleteLike.call(current_user, playlist)
                        
                        present :success, true
                    end
                end
            end

        end
    end
end