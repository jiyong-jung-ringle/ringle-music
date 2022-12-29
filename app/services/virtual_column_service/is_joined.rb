module VirtualColumnService
    class IsJoined < ApplicationService

        def initialize(current_user, model)
            @model = model
            @user_groups_name = UserGroup.table_name
            @join_subquery = "SELECT `#{@user_groups_name}`.* FROM `#{@user_groups_name}` WHERE `#{@user_groups_name}`.user_id = #{current_user.id}"
            @join_condition = "`#{model.table_name}`.id = `#{@user_groups_name}`.group_id"
            @case_indicator = "CASE WHEN `#{@user_groups_name}`.user_id = #{current_user.id} THEN true ELSE false END"
        end

        def call
            return @model
            .joins("LEFT OUTER JOIN (#{@join_subquery}) AS `#{@user_groups_name}` ON (#{@join_condition})")
            .select("`#{@model.table_name}`.*, #{@case_indicator} AS is_joined")
        end

    end

end