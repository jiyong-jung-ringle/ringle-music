module V1
    class PlaylistApi < Grape::API
        resource :playlists do
            params do
                optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR], default: FeedService::OrderFilterStatus::POPULAR
            end
            get do
                authenticate!
                playlists = FeedService::PlaylistsGetter.call(current_user, params[:filter], params[:page_number], params[:limit])
                
                data = {total_playlists_count: playlists[:total_playlists_count],
                    playlists: (Entities::PlaylistBasic.represent playlists[:playlists], current_user_likes: current_user_likes(Playlist), current_user_groups: current_user_groups)}
                present data, with: Entities::Default, success: true
            end

            route_param :playlist_id, type: Integer do
                params do
                    optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                    optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                    optional :keyword, type: String
                    optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                end
                get do
                    authenticate!
                    error_text!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    musics = FeedService::PlaylistMusicsGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:page_number], params[:limit])
                    
                    data = {total_musics_count: musics[:total_musics_count],
                        musics: (Entities::MusicBasic.represent musics[:musics], in_playlist: true, current_user_likes: current_user_likes(Music))}
                    present data, with: Entities::Default, success: true
                end
                params do
                    requires :music_ids, type: Array[Integer]
                end
                post do
                    authenticate!
                    error_text!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    error_text!("You cannot modify this playlist") unless playlist.include_user?(user: current_user)
                    error_text!("Cannot add musics") unless result = PlaylistService::AddMusic.call(current_user, playlist, params[:music_ids])
                    
                    present data={}, with: Entities::Default, success: true
                end
                params do
                    requires :music_ids, type: Array[Integer]
                end
                delete do
                    authenticate!
                    error_text!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    error_text!("You cannot modify this playlist") unless playlist.include_user?(user: current_user)
                    error_text!("Cannot delete musics") unless result = PlaylistService::DeleteMusic.call(current_user, playlist, params[:music_ids])
                    
                    present data={}, with: Entities::Default, success: true
                end

                resource :likes do
                    params do
                        optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                        optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error_text!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        likes = FeedService::LikesGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:page_number], params[:limit])

                        data = {total_likes_count: likes[:total_likes_count],
                            like_users: (Entities::UserBasic.represent likes[:like_users], with_like: true)}
                        present data, with: Entities::Default, success: true
                    end

                    post do
                        authenticate!
                        error_text!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error_text!("Already liked") unless LikeService::CreateLike.call(current_user, playlist)
                        
                        present data={}, with: Entities::Default, success: true
                    end

                    delete do
                        authenticate!
                        error_text!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error_text!("Already unliked") unless LikeService::DeleteLike.call(current_user, playlist)
                        
                        present data={}, with: Entities::Default, success: true
                    end
                end
            end

        end
    end
end