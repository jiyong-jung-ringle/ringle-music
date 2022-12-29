module VirtualColumnService
    class IsJoined < ApplicationService

        def initialize(current_user, model)
            @model = model
            @current_user = current_user
            @user_groups_name = UserGroup.table_name
        end

        def call
            if @current_user
                get_join_subquery
                get_join_condition
                get_case_indicator
                return @model
                    .joins("LEFT OUTER JOIN (#{@join_subquery}) AS `#{@user_groups_name}` ON (#{@join_condition})")
                    .select("`#{@model.table_name}`.*, #{@case_indicator} AS is_joined")
            else
                return @model.select("`#{@model.table_name}`.*, #{false} AS is_joined")
            end
        end

        private
        def get_join_subquery
            @join_subquery = "SELECT `#{@user_groups_name}`.* FROM `#{@user_groups_name}` WHERE `#{@user_groups_name}`.user_id = #{@current_user.id}"
        end
        def get_join_condition
            @join_condition = "`#{@model.table_name}`.id = `#{@user_groups_name}`.group_id"
        end
        def get_case_indicator
            @case_indicator = "CASE WHEN `#{@user_groups_name}`.user_id = #{@current_user.id} THEN #{true} ELSE #{false} END"
        end

    end

end