module AuthService
    class JwtValidator < ApplicationService
        def initialize(jwt)
            @jwt = jwt
        end
        def call
            validate_token
        end

        private
        def validate_token
            begin
                decoder = AuthService::JwtDecoder.new(@jwt)
                payload = decoder.call
                user_id = payload[:id]
                return nil if payload[:exp] < Time.now.to_i
                payload_without_verification = decoder.call(false)
                user_id_without_verification = payload_without_verification[:id]
                return user_id == user_id_without_verification ? User.find_by(id: user_id) : nil
            rescue => e
                return nil
            end
        end
    end
end