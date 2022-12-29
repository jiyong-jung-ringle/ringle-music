module V1
    class UserApi < Grape::API
        resource :user do
            get do
                authenticate!
                user_info = UserService::GetInfo::call(current_user)
                return {
                    user: user_info
                }
            end

            params do
                requires :name, type: String
            end
            patch do
                authenticate!
                UserService::ChangeName.call(current_user, params[:name])
                return {
                    success: true
                }
            end

            resource :like do
                resource :music do
                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        musics = FeedService::LikeMusicsGetter.call(current_user, params[:keyword], params[:filter], params[:offset], params[:limit])
                        return {
                            total_musics_count: musics[:total_musics_count],
                            musics: musics[:musics]
                        }
                    end
                end
                resource :playlist do
                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR], default: FeedService::OrderFilterStatus::RECENT
                    end
                    get do
                        authenticate!
                        playlists = FeedService::LikePlaylistsGetter.call(current_user, params[:filter], params[:offset], params[:limit])
                        return {
                            total_playlists_count: playlists[:total_playlists_count],
                            playlists: playlists[:playlists]
                        }
                    end
                end
            end

            resource :list do
                params do
                    optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                    optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                    optional :keyword, type: String
                    optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                end
                get do
                    authenticate!
                    users = FeedService::UsersGetter.call(params[:keyword], params[:filter], params[:offset], params[:limit])
                    return {
                        total_users_count: users[:total_users_count],
                        users: users[:users]
                    }
                end
            end

            params do
                requires :user_id, type: Integer
            end
            route_param :user_id do
                get do
                    authenticate!
                    error!("User not found") unless user = User.find_by(id: params[:user_id])
                    user_info = UserService::GetInfo::call(user)
                    return {
                        user: user_info
                    }
                end
            end

        end
    end
end