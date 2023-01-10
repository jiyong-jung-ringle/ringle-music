module AuthService
  class JwtCreator < ApplicationService
    def initialize(user)
      @payload = { id: user.id, exp: (Time.now + 3.months).to_i }
    end
    def call
      create_jwt
    end

      private
        def create_jwt
          AuthService::JwtEncoder.call(@payload)
        end
  end
end
