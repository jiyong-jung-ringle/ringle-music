module UserService
    class GetInfo < ApplicationService

        def initialize(current_user)
            @current_user = current_user
        end

        def call
            get_user_info
            return @user_info
        end

        private
        def get_user_info
            @user_info = @current_user.as_json({
                only: [
                    :id,
                    :name,
                    :created_at,
                    :email,
                ]
            })
        end

    end

end