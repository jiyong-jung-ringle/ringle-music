module V1
    class MusicApi < Grape::API
        resource :musics do
            params do
                optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                optional :keyword, type: String
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
            end
            get do
                authenticate!
                musics = FeedService::MusicsGetter.call(current_user, params[:keyword], params[:filter], params[:page_number], params[:limit])

                data = {total_musics_count: musics[:total_musics_count],
                    musics: (Entities::MusicBasic.represent musics[:musics], current_user_likes: current_user_likes(Music))}
                present data, with: Entities::Default, success: true
            end

            route_param :music_id, type: Integer do
                resource :likes do

                    params do
                        optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                        optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error_text!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        likes = FeedService::LikesGetter.call(current_user, music, params[:keyword], params[:filter], params[:page_number], params[:limit])


                        data = {total_likes_count: likes[:total_likes_count],
                            like_users: (Entities::UserBasic.represent likes[:like_users], with_like: true)}
                        present data, with: Entities::Default, success: true
                    end

                    post do
                        authenticate!
                        error_text!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error_text!("Already liked") unless LikeService::CreateLike.call(current_user, music)
                        
                        present data={}, with: Entities::Default, success: true
                    end

                    delete do
                        authenticate!
                        error_text!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error_text!("Already unliked") unless LikeService::DeleteLike.call(current_user, music)
                        
                        present data={}, with: Entities::Default, success: true
                    end
                end
            end

        end
    end
end