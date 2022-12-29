module UserService
    class ChangeName < ApplicationService

        def initialize(current_user, name)
            @current_user = current_user
            @name = name
        end

        def call
            get_user_info
            return @user_info
        end

        private
        def get_user_info
            @success = @current_user.change_name!(name: @name)
        end

    end

end