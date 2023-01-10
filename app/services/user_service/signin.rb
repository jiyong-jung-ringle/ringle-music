module UserService
  class Signin < ApplicationService
    def initialize(email, password)
      @email = email
      @password = password
    end

    def call
      do_signin
    end

      private
        def do_signin
          @success = true
          return nil unless user = User.find_by(email: @email)
          return nil unless user.authenticate(@password)
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
