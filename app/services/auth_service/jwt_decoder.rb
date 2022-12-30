module AuthService
    class JwtDecoder < ApplicationService
        def initialize(jwt)
            @jwt = jwt
        end
        def call(verify=true)
            verify ? decode : decode_without_verification
            return @payload[0].with_indifferent_access
        end

        private
        def decode_without_verification
            @payload = JWT.decode(@jwt, nil, false, {algorithm: 'RS256'})
        end
        def decode
            @payload = JWT.decode(@jwt, PUBLIC_KEY, true, {algorithm: 'RS256'})
        end
    end
end