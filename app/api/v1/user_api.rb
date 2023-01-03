module V1
    class UserApi < Grape::API
        resource :users do
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
            resource :info do
                get do
                    authenticate!
                    user_info = UserService::GetInfo::call(current_user)
                    return {
                        user: user_info
                    }
                end

                resource :password do
                    params do
                        requires :new_password, type: String, values: {proc: ->(password) {password!=""}}
                        requires :old_password, type: String, values: {proc: ->(password) {password!=""}}
                    end
                    patch do
                        authenticate_with_password!(params[:old_password])
                        error!("Cannot change password") unless UserService::ChangePassword.call(current_user, params[:new_password])
                        return {
                            success: true
                        }
                    end
                end

                resource :name do
                    params do
                        requires :name, type: String
                        requires :password, type: String, values: {proc: ->(password) {password!=""}}
                    end
                    patch do
                        authenticate_with_password!(params[:password])
                        error!("Cannot modify name") unless UserService::ChangeName.call(current_user, params[:name])
                        return {
                            success: true
                        }
                    end
                end
            end

            resource :signup do
                params do
                    requires :email, type: String, values: {proc: ->(name) {name!=""}}, regexp: URI::MailTo::EMAIL_REGEXP
                    requires :name, type: String, values: {proc: ->(name) {name!=""}}
                    requires :password, type: String, values: {proc: ->(password) {password!=""}}
                end
                post do
                    error!("Already signned. Please logout") if authenticate?
                    error!("Please use different Email address") unless result = UserService::Signup.call(params[:email], params[:name], params[:password])
                    return result
                end
            end

            resource :signin do
                params do
                    requires :email, type: String, values: {proc: ->(name) {name!=""}}, regexp: URI::MailTo::EMAIL_REGEXP
                    requires :password, type: String, values: {proc: ->(password) {password!=""}}
                end
                get do
                    error!("Already signned. Please logout") if authenticate?
                    error!("Login Failed") unless result = UserService::Signin.call(params[:email], params[:password])
                    return result
                end
            end

            resource :likes do
                resource :musics do
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
                resource :playlists do
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

            route_param :user_id, type: Integer do
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