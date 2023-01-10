module AuthService
  class JwtEncoder < ApplicationService
    def initialize(payload)
      @payload = payload
    end
    def call
      encode_jwt
    end
    def encode_jwt
      JWT.encode(@payload, SECRET_KEY, "RS256")
    end
  end
end
