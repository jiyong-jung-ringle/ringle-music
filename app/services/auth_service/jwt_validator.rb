module AuthService
    class JwtValidator < ApplicationService
        def initialize(jwt)
            @jwt = jwt
        end
        def call
            validate_token
            return @user
        end

        private
        def validate_token
            begin
                decoder = AuthService::JwtDecoder.new(@jwt)
                payload = decoder.call
                user_id = payload[:id]
                return @user = nil if payload[:exp] < Time.now.to_i
                payload_without_verification = decoder.call(false)
                user_id_without_verification = payload_without_verification[:id]
                return user_id == user_id_without_verification ? @user = User.find_by(id: user_id) : @user = nil
            rescue => e
                return @user = nil
            end
        end
    end
end