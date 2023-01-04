module FeedService
    class LikePlaylistsGetter < ApplicationService

        def initialize(user, filter, page_number, limit)
            @filter = filter
            @limit = limit
            @page_number = page_number
            @user = user
            @model = Playlist
        end

        def call
            get_join_indicator
            get_liked_playlists
            get_order
            get_playlists
        end

        private
        def get_join_indicator
            @likes_name = Like.table_name
            join_condition = "`#{@likes_name}`.likable_type = '#{@model.to_s}' AND `#{@likes_name}`.likable_id = `#{@model.table_name}`.id"
            @join_indicator = "INNER JOIN `#{@model.table_name}` ON (#{join_condition})"
        end
        def get_liked_playlists
            @playlists = @user.likes.joins(@join_indicator)
            .select("#{@model.table_name}.*, #{@likes_name}.created_at AS liked_at")
        end

        def get_order
            @playlists_ordered = OrderedModelGetter.call(@playlists, "", @filter, [OrderFilterStatus::RECENT, OrderFilterStatus::POPULAR], [])
        end

        def get_playlists
            musics_result = (@playlists_ordered.
                offset(@limit*@page_number).limit(@limit))
            ownable_ids = musics_result.as_json({
                only: [
                    :ownable_type,
                    :ownable_id,
                ]
            })
            owanble_hash = Hash.new
            ownable_ids.each { |data|
                hash_data = data.with_indifferent_access
                owanble_hash[hash_data[:ownable_type]]==nil ? owanble_hash[hash_data[:ownable_type]] = [hash_data[:ownable_id]] : owanble_hash[hash_data[:ownable_type]] = owanble_hash[hash_data[:ownable_type]]+[hash_data[:ownable_id]]
            }
            ownable_user = ModelPreload.new(User, {id: owanble_hash[User.to_s]})
            ownable_group = ModelPreload.new(Group, {id: owanble_hash[Group.to_s]})
            musics_playlists_as_json = musics_result.as_json({
                only: [
                    :id,
                    :likes_count,
                    :liked_at,
                    :musics_count,
                    :ownable_type,
                    :ownable_id,
                ]
            }).map {|json|
                json = json.with_indifferent_access
                json.except(:ownable_id).merge!(
                    ownable: 
                        case json[:ownable_type]
                            when User.to_s
                                ownable_user.call(id: json[:ownable_id])
                                &.as_json({only:[:id, :name]})
                            when Group.to_s
                                ownable_group.call(id: json[:ownable_id])
                                &.as_json({only:[:id, :name, :users_count]})
                            else
                                nil
                        end
                )
            }
            {
                total_playlists_count: @user.likes.where(likable_type: @model.to_s).count,
                playlists: musics_playlists_as_json
            }
        end
        
    end
end