module V1
    class MusicApi < Grape::API
        resource :music do
            get do
                return {
                    result: "hi"
                }
            end
        end
    end
end