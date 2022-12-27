module V1
    class MusicApi < Grape::API
        resource :music do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 30 } }, default: 20
                optional :keyword, type: String
                optional :filter, type: String, values: [Feed::OrderFilterStatus::RECENT, Feed::OrderFilterStatus::POPULAR, Feed::OrderFilterStatus::EXACT], default: Feed::OrderFilterStatus::EXACT
            end
            get do
                current_user = User.third
                musics = Feed::MusicGetter.call(current_user, params[:keyword], params[:filter], params[:limit])
                return {
                    total_music: musics[:total_music],
                    musics: musics[:musics]
                }
            end
        end
    end
end