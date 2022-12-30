module AuthService
    class JwtEncoder < ApplicationService
        def initialize(payload)
            @jwt = JWT.encode(payload, SECRET_KEY, 'RS256')
        end
        def call
            return @jwt
        end
    end
end