module VirtualColumnService
    class IsLiked < ApplicationService

        def initialize(current_user, model, likbale_model_name)
            @model = model
            @likes_name = Like.table_name
            @join_subquery = "SELECT `#{@likes_name}`.* FROM `#{@likes_name}` WHERE `#{@likes_name}`.user_id = #{current_user.id}"
            @join_condition = "`#{@likes_name}`.likable_type = '#{likbale_model_name.to_s}' AND `#{@likes_name}`.likable_id = `#{likbale_model_name.table_name}`.id"
            @case_indicator = "CASE WHEN `#{@likes_name}`.user_id = #{current_user.id} THEN true ELSE false END"
        end

        def call
            return @model
            .joins("LEFT OUTER JOIN (#{@join_subquery}) AS `#{@likes_name}` ON (#{@join_condition})")
            .select("`#{@model.table_name}`.*, #{@case_indicator} AS is_liked")
        end

    end

end