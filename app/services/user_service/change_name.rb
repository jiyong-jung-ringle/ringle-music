module UserService
    class ChangeName < ApplicationService

        def initialize(current_user, name)
            @current_user = current_user
            @name = name
        end

        def call
            change_name
            return @user_info
        end

        private
        def change_name
            @success = @current_user.change_name!(name: @name)
        end

    end

end