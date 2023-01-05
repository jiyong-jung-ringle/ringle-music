module ErrorHandlers
    extend ActiveSupport::Concern
    
    included do
        rescue_from :all do |e|
            ENV["RAILS_ENV"]=="development" ? error!({error: e, backtrace: e.backtrace[0..([2, e.backtrace.length].min)]}) : error!({error: "Internal Server Error : #{e}"})
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
            error!(e)
        end

        route :any, '*path' do
            error!({error: "Invalid route: \"#{request.path}\""}, 404)
        end
    end
end