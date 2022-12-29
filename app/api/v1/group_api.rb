module V1
    class GroupApi < Grape::API
        resource :group do
            params do
                optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                optional :keyword, type: String
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
            end
            get do
                authenticate!
                groups = FeedService::GroupsGetter.call(current_user, params[:keyword], params[:filter], params[:offset], params[:limit])
                return {
                    total_groups_count: groups[:total_groups_count],
                    groups: groups[:groups]
                }
            end

            params do
                requires :name, type: String
                optional :user_ids, type: Array[Integer], default: []
            end
            post do
                authenticate!
                error!("cannot make group") unless result = GroupService::CreateGroup.call(current_user, params[:name], params[:user_ids])
                return result
            end

            params do
                requires :group_id, type: Integer
            end
            route_param :group_id do
                put do
                    authenticate!
                    error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                    error!("Already joined") unless result = GroupService::JoinGroup.call(current_user, group, [])
                    return {
                        success: result[:"#{current_user.id}"]
                    }
                end
                delete do
                    authenticate!
                    error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                    error!("Not joined this group") unless result = GroupService::ExitGroup.call(current_user, group, [])
                    return {
                        success: result[:"#{current_user.id}"]
                    }
                end
                params do
                    requires :name, type: String
                end
                patch do
                    authenticate!
                    error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                    error!("Cannot modify group name") unless group.include_user?(user: current_user)
                    GroupService::ChangeGroupName.call(current_user, group, params[:name])
                    return {
                        success: true
                    }
                end


                resource :user do
                    params do
                        optional :limit, type: Integer, values: { proc: ->(limit) { limit.positive? && limit <= 100 } }, default: 50
                        optional :offset, type: Integer, values: { proc: ->(offset) { offset.positive? || offset==0 } }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                        users = FeedService::GroupUsersGetter.call(current_user, group, params[:keyword], params[:filter], params[:offset], params[:limit])
                        return {
                            total_users_count: users[:total_users_count],
                            users: users[:users]
                        }
                    end
                end
            end

        end
    end
end