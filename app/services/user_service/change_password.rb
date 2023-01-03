module UserService
    class ChangePassword < ApplicationService

        def initialize(current_user, password)
            @current_user = current_user
            @password = password
        end

        def call
            change_password
        end

        private
        def change_password
            @current_user.change_password!(password: @password)
        end

    end

end