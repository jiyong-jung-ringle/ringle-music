module V1
    class MusicApi < Grape::API
        resource :musics do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                optional :keyword, type: String
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
            end
            get do
                authenticate!
                musics = FeedService::MusicsGetter.call(current_user, params[:keyword], params[:filter], params[:offset], params[:limit])
                return {
                    total_musics_count: musics[:total_musics_count],
                    musics: musics[:musics]
                }
            end

            params do
                requires :music_id, type: Integer
            end
            route_param :music_id do
                resource :likes do

                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        likes = FeedService::LikesGetter.call(current_user, music, params[:keyword], params[:filter], params[:offset], params[:limit])
                        return {
                            total_likes_count: likes[:total_likes_count],
                            like_users: likes[:like_users]
                        }
                    end

                    post do
                        authenticate!
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error!("Already liked") unless LikeService::CreateLike.call(current_user, music)
                        return {
                            success: true
                        }
                    end

                    delete do
                        authenticate!
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error!("Already unliked") unless LikeService::DeleteLike.call(current_user, music)
                        return {
                            success: true
                        }
                    end
                end
            end

        end
    end
end