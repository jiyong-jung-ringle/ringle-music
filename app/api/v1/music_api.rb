module V1
    class MusicApi < Grape::API
        resource :musics do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                optional :page_number, type: Integer, values: { proc: ->(page_number) { page_number.positive? || page_number==0 } }, default: 0
                optional :keyword, type: String
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
            end
            get do
                authenticate!
                musics = FeedService::MusicsGetter.call(current_user, params[:keyword], params[:filter], params[:page_number], params[:limit])

                present :success, true
                present :total_musics_count, musics[:total_musics_count]
                present :musics, musics[:musics], with: Entities::MusicEntity, current_user_likes: current_user_likes(Music)
            end

            route_param :music_id, type: Integer do
                resource :likes do

                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :page_number, type: Integer, values: { proc: ->(page_number) { page_number.positive? || page_number==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        likes = FeedService::LikesGetter.call(current_user, music, params[:keyword], params[:filter], params[:page_number], params[:limit])

                        present :success, true
                        present :total_likes_count, likes[:total_likes_count]
                        present :like_users, likes[:like_users], with: Entities::UserEntity, with_like: true
                    end

                    post do
                        authenticate!
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error!("Already liked") unless LikeService::CreateLike.call(current_user, music)
                        
                        present :success, true
                    end

                    delete do
                        authenticate!
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error!("Already unliked") unless LikeService::DeleteLike.call(current_user, music)
                        
                        present :success, true
                    end
                end
            end

        end
    end
end