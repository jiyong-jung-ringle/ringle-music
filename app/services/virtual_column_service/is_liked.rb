module VirtualColumnService
    class IsLiked < ApplicationService

        def initialize(current_user, model, likbale_model_name)
            @model = model
            @current_user = current_user
            @likes_name = Like.table_name
            @likbale_model_name = likbale_model_name
        end

        def call
            if @current_user 
                get_join_subquery
                get_join_condition
                get_case_indicator
                return @model
                    .joins("LEFT OUTER JOIN (#{@join_subquery}) AS `#{@likes_name}` ON (#{@join_condition})")
                    .select("`#{@model.table_name}`.*, #{@case_indicator} AS is_liked")
            else
                return @model.select("`#{@model.table_name}`.*, #{false} AS is_liked")
            end
        end

        private
        def get_join_subquery
            @join_subquery = "SELECT `#{@likes_name}`.* FROM `#{@likes_name}` WHERE `#{@likes_name}`.user_id = #{@current_user.id}"
        end
        def get_join_condition
            @join_condition = "`#{@likes_name}`.likable_type = '#{@likbale_model_name.to_s}' AND `#{@likes_name}`.likable_id = `#{@likbale_model_name.table_name}`.id"
        end
        def get_case_indicator
            @case_indicator = "CASE WHEN `#{@likes_name}`.user_id = #{@current_user.id} THEN true ELSE false END"
        end

    end

end