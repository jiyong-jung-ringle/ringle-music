module V1
  module CurrentUserHelper
    def error_text!(text, error_code = 400)
      error!((Entities::Default.represent result = { error: text }, success: false), error_code)
    end

    def current_user
      return @current_user if @current_user
      if request.headers["Authorization"]
        jwt = request.headers["Authorization"].split(" ").last
        return @current_user = AuthService::JwtValidator.call(jwt)
      end
      @current_user = nil
    end

    def current_user_likes(model)
      @current_user_likes = UserService::UserLikes.new(model, current_user) unless @current_user_likes
    end

    def current_user_groups
      @current_user_groups = UserService::UserGroups.new(current_user) unless @current_user_groups
    end

    def authenticate!
      error_text!("Unauthorized", 401) unless current_user
    end

    def authenticate_with_password!(password)
      error_text!("Unauthorized", 401) unless current_user
      error_text!("Password Invalid", 401) unless current_user.authenticate(password)
    end

    def authenticate?
      current_user ? true : false
    end
  end
end
