module UserService
    class Signup < ApplicationService

        def initialize(email, name, password)
            @email = email
            @name = name
            @password = password
        end

        def call
            do_signup
            return @success ? {
                jwt: @jwt,
                user: @user.as_json(
                    only: [
                        :id, 
                        :name, 
                        :email
                    ]
                )
            } : nil
        end

        private
        def do_signup
            @success = true
            @user = User.create_user!(email: @email, name: @name, password: @password)
            return @success = false unless @user
            @jwt = AuthService::JwtCreator.call(@user)
        end

    end

end