module V1
    module CurrentUserHelper
        def current_user
            return @current_user if @current_user
            if request.headers['Authorization']
                jwt = request.headers['Authorization'].split(' ').last
                @current_user = AuthService::JwtValidator.call(jwt)
                return @current_user
            end
            return @current_user = nil
        end

        def current_user_likes(model)
            @current_user_likes = UserService::UserLikes.new(model, current_user) unless @current_user_likes
            return @current_user_likes
        end
        
        def current_user_groups
            @current_user_groups = UserService::UserGroups.new(current_user) unless @current_user_groups
            return @current_user_groups
        end

        def authenticate!
            error!('Unauthorized') unless current_user
        end

        def authenticate_with_password!(password)
            error!('Unauthorized') unless current_user
            error!('Password Invalid') unless current_user.authenticate(password)
        end

        def authenticate?
           current_user ? true : false
        end
    end
end