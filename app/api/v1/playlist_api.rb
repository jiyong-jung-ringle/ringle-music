module V1
    class PlaylistApi < Grape::API
        resource :playlists do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR], default: FeedService::OrderFilterStatus::POPULAR
            end
            get do
                authenticate!
                playlists = FeedService::PlaylistsGetter.call(current_user, params[:filter], params[:offset], params[:limit])
                return {
                    total_playlists_count: playlists[:total_playlists_count],
                    playlists: playlists[:playlists]
                }
            end

            params do
                requires :playlist_id, type: Integer
            end
            route_param :playlist_id do
                params do
                    optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                    optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                    optional :keyword, type: String
                    optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                end
                get do
                    authenticate!
                    error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    musics = FeedService::PlaylistMusicsGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:offset], params[:limit])
                    return {
                        total_musics_count: musics[:total_musics_count],
                        musics: musics[:musics]
                    }
                end
                params do
                    requires :music_ids, type: Array[Integer]
                end
                post do
                    authenticate!
                    error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    error!("You cannot modify this playlist") unless playlist.include_user?(user: current_user)
                    error!("Cannot add musics") unless result = PlaylistService::AddMusic.call(current_user, playlist, params[:music_ids])
                    return {
                        success: result
                    }
                end
                params do
                    requires :music_ids, type: Array[Integer]
                end
                delete do
                    authenticate!
                    error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    error!("You cannot modify this playlist") unless playlist.include_user?(user: current_user)
                    error!("Cannot delete musics") unless result = PlaylistService::DeleteMusic.call(current_user, playlist, params[:music_ids])
                    return {
                        success: result
                    }
                end

                resource :likes do
                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        likes = FeedService::LikesGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:offset], params[:limit])
                        return {
                            total_likes_count: likes[:total_likes_count],
                            like_users: likes[:like_users]
                        }
                    end

                    post do
                        authenticate!
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error!("Already liked") unless LikeService::CreateLike.call(current_user, playlist)
                        return {
                            success: true
                        }
                    end

                    delete do
                        authenticate!
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error!("Already unliked") unless LikeService::DeleteLike.call(current_user, playlist)
                        return {
                            success: true
                        }
                    end
                end
            end

        end
    end
end