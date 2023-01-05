module V1
    class UserApi < Grape::API
        resource :users do
            params do
                optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                optional :keyword, type: String
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
            end
            get do
                authenticate!
                users = FeedService::UsersGetter.call(params[:keyword], params[:filter], params[:page_number], params[:limit])
                
                present :success, true
                present :total_users_count, users[:total_users_count]
                present :users, users[:users], with: Entities::UserEntity
            end
            resource :info do
                get do
                    authenticate!
                    user_info = UserService::GetInfo::call(current_user)

                    present :success, true
                    present :user, user_info, with: Entities::UserEntity, with_full: true
                end

                resource :password do
                    params do
                        requires :new_password, type: String, values: lambda {|new_password| new_password.present? }
                        requires :old_password, type: String, values: lambda {|old_password| old_password.present? }
                    end
                    patch do
                        authenticate_with_password!(params[:old_password])
                        error!("Cannot change password") unless UserService::ChangePassword.call(current_user, params[:new_password])
                        present :success, true
                    end
                end

                resource :name do
                    params do
                        requires :name, type: String, values: lambda {|name| name.present? }
                        requires :password, type: String, values: lambda {|password| password.present? }
                    end
                    patch do
                        authenticate_with_password!(params[:password])
                        error!("Cannot modify name") unless UserService::ChangeName.call(current_user, params[:name])
                        present :success, true
                    end
                end
            end

            resource :signup do
                params do
                    requires :email, type: String, values: lambda {|email| email.present? }, regexp: URI::MailTo::EMAIL_REGEXP
                    requires :name, type: String, values: lambda {|name| name.present? }
                    requires :password, type: String, values: lambda {|password| password.present? }
                end
                post do
                    error!("Already signned. Please logout") if authenticate?
                    error!("Please use different Email address") unless result = UserService::Signup.call(params[:email], params[:name], params[:password])
                    present result
                end
            end

            resource :signin do
                params do
                    requires :email, type: String, values: lambda {|email| email.present? }, regexp: URI::MailTo::EMAIL_REGEXP
                    requires :password, type: String, values: lambda {|password| password.present? }
                end
                get do
                    error!("Already signned. Please logout") if authenticate?
                    error!("Login Failed") unless result = UserService::Signin.call(params[:email], params[:password])
                    present result
                end
            end

            resource :likes do
                resource :musics do
                    params do
                        optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                        optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        musics = FeedService::LikeMusicsGetter.call(current_user, params[:keyword], params[:filter], params[:page_number], params[:limit])
                        
                        present :success, true
                        present :total_musics_count, musics[:total_musics_count]
                        present :musics, musics[:musics], with: Entities::MusicEntity, with_liked: true, current_user_likes: current_user_likes(Music)
                    end
                end
                resource :playlists do
                    params do
                        optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                        optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR], default: FeedService::OrderFilterStatus::RECENT
                    end
                    get do
                        authenticate!
                        playlists = FeedService::LikePlaylistsGetter.call(current_user, params[:filter], params[:page_number], params[:limit])
                        
                        present :success, true
                        present :total_playlists_count, playlists[:total_playlists_count]
                        present :playlists, playlists[:playlists], with: Entities::PlaylistEntity, current_user_likes: current_user_likes(Playlist), current_user_groups: current_user_groups
                    end
                end
            end

            route_param :user_id, type: Integer do
                get do
                    authenticate!
                    error!("User not found") unless user = User.find_by(id: params[:user_id])
                    user_info = UserService::GetInfo::call(user)
                    
                    present :success, true
                    present :user, user_info, with: Entities::UserEntity, with_full: true
                end
            end

        end
    end
end