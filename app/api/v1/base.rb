module V1
    class Base < Grape::API
        format :json
        content_type :json, 'application/json'

        version 'v1', using: :path

        namespace do
            mount TestApi
        end
    end
end
  