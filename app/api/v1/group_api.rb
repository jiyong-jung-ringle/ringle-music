module V1
    class GroupApi < Grape::API
        resource :groups do
            params do
                optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                optional :keyword, type: String
                optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
            end
            get do
                authenticate!
                groups = FeedService::GroupsGetter.call(current_user, params[:keyword], params[:filter], params[:page_number], params[:limit])

                data = {total_groups_count: groups[:total_groups_count],
                    users: (Entities::GroupBasic.represent groups[:groups], current_user_groups: current_user_groups)}
                present data, with: Entities::Default, success: true
            end

            params do
                requires :name, type: String
                optional :user_ids, type: Array[Integer], default: []
            end
            post do
                authenticate!
                error!("cannot make group") unless result = GroupService::CreateGroup.call(current_user, params[:name], params[:user_ids])
                present result, with: Entities::Default, success: true
            end

            route_param :group_id, type: Integer do
                put do
                    authenticate!
                    error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                    error!("Already joined") unless join_group_user_ids = GroupService::JoinGroup.call(current_user, group, [])
                    
                    present data={:success=> join_group_user_ids[:"#{current_user.id}"]}, with: Entities::Default, success: true
                end
                delete do
                    authenticate!
                    error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                    error!("Not joined this group") unless exit_group_user_ids = GroupService::ExitGroup.call(current_user, group, [])
                    
                    present data={:success=> exit_group_user_ids[:"#{current_user.id}"]}, with: Entities::Default, success: true
                end
                params do
                    requires :name, type: String
                end
                patch do
                    authenticate!
                    error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                    error!("Cannot modify group name") unless group.include_user?(user: current_user)
                    error!("Cannot change group name") unless GroupService::ChangeGroupName.call(current_user, group, params[:name])
                    
                    present data={}, with: Entities::Default, success: true
                end


                resource :users do
                    params do
                        optional :limit, type: Integer, values: lambda {|limit| limit.positive? && limit <= 100 }, default: 50
                        optional :page_number, type: Integer, values: lambda {|page_number| page_number.positive? || page_number==0 }, default: 0
                        optional :keyword, type: String
                        optional :filter, type: String, values: [FeedService::OrderFilterStatus::RECENT, FeedService::OrderFilterStatus::EXACT], default: FeedService::OrderFilterStatus::EXACT
                    end
                    get do
                        authenticate!
                        error!("Group does not exist") unless group = Group.find_by(id: params[:group_id])
                        users = FeedService::GroupUsersGetter.call(current_user, group, params[:keyword], params[:filter], params[:page_number], params[:limit])
                        
                        data = {total_users_count: users[:total_users_count],
                        users: (Entities::UserBasic.represent users[:users], with_join: true)}
                        present data, with: Entities::Default, success: true
                    end
                end
            end

        end
    end
end