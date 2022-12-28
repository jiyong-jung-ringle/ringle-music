module V1
    class MusicApi < Grape::API
        resource :music do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                optional :keyword, type: String
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::POPULAR, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
            end
            get do
                current_user = User.third
                musics = FeedService::MusicsGetter.call(current_user, Music, params[:keyword], params[:filter], params[:offset], params[:limit])
                return {
                    total_musics_count: musics[:total_musics_count],
                    musics: musics[:musics]
                }
            end

            params do
                requires :music_id, type: Integer
            end
            route_param :music_id do
                resource :like do

                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        current_user = User.third
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        likes = FeedService::LikesGetter.call(current_user, music, params[:keyword], params[:filter], params[:offset], params[:limit])
                        return {
                            total_likes_count: likes[:total_likes_count],
                            like_users: likes[:like_users]
                        }
                    end

                    post do
                        current_user = User.third
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error!("Alread liked") unless LikeService::ModifyLike.call(current_user, music, LikeService::LikeAction::POST)
                        return {
                            success: true
                        }
                    end

                    delete do
                        current_user = User.third
                        error!("Music does not exist") unless music = Music.find_by(id: params[:music_id])
                        error!("Alread unliked") unless LikeService::ModifyLike.call(current_user, music, LikeService::LikeAction::DELETE)
                        return {
                            success: true
                        }
                    end
                end
            end

        end
    end
end