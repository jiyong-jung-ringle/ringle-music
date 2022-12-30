module AuthService
    class JwtCreator < ApplicationService
        def initialize(user)
            @payload = {id: user.id, exp: (Time.now + 1.days).to_i}
        end
        def call
            create_jwt
            return @jwt
        end
        private
        def create_jwt
            @jwt = AuthService::JwtEncoder.call(@payload)
        end
    end
end