module UserService
    class Signin < ApplicationService

        def initialize(email, password)
            @email = email
            @password = password
        end

        def call
            do_signin
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
        def do_signin
            @success = true
            return @success = false unless @user = User.find_by(email: @email)
            return @success = false unless @user.authenticate(@password)
            @jwt = AuthService::JwtCreator.call(@user)
        end

    end

end