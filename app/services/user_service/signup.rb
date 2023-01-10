module UserService
  class Signup < ApplicationService
    def initialize(email, name, password)
      @email = email
      @name = name
      @password = password
    end

    def call
      do_signup
    end

      private
        def do_signup
          user = User.create_user!(email: @email, name: @name, password: @password)
          return nil unless user
          {
              jwt: AuthService::JwtCreator.call(user),
              user: user.as_json(
                  only: [
                      :id,
                      :name,
                      :email
                  ]
                )
          }
        end
  end
end
