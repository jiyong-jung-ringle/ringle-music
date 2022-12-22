module V1
    class TestApi < Grape::API
        resource :test do
            get do
                return {
                    result: "hi"
                }
            end
        end
    end
end