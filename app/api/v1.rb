module V1
    module CurrentUserHelper
        def current_user
            return @current_user if @current_user
            @current_user = User.third
            return @current_user
        end

        def authenticate!
            error!('Unauthorized') unless current_user
        end
    end
end