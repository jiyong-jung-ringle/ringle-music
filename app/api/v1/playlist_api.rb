module V1
    class PlaylistApi < Grape::API
        resource :playlist do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR], default: FeedService::OrderFilterStatus::POPULAR
            end
            get do
                current_user = User.third
                playlists = FeedService::PlaylistsGetter.call(current_user, Playlist, params[:filter], params[:offset], params[:limit])
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
                    current_user = User.third
                    error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                    musics = FeedService::PlaylistMusicsGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:offset], params[:limit])
                    return {
                        total_musics_count: musics[:total_musics_count],
                        musics: musics[:musics]
                    }
                end

                resource :like do
                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        current_user = User.third
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        likes = FeedService::LikesGetter.call(current_user, playlist, params[:keyword], params[:filter], params[:offset], params[:limit])
                        return {
                            total_likes_count: likes[:total_likes_count],
                            like_users: likes[:like_users]
                        }
                    end

                    post do
                        current_user = User.third
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error!("Alread liked") unless LikeService::ModifyLike.call(current_user, playlist, LikeService::LikeAction::POST)
                        return {
                            success: true
                        }
                    end

                    delete do
                        current_user = User.third
                        error!("Playlist does not exist") unless playlist = Playlist.find_by(id: params[:playlist_id])
                        error!("Alread unliked") unless LikeService::ModifyLike.call(current_user, playlist, LikeService::LikeAction::DELETE)
                        return {
                            success: true
                        }
                    end
                end
            end

        end
    end
end