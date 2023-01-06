module ErrorHandlers
  extend ActiveSupport::Concern

  included do
    rescue_from :all do |e|
      ENV["RAILS_ENV"] == "development" ? error!((Entities::Default.represent result = { error: e, backtrace: e.backtrace[0..([2, e.backtrace.length].min)] }, success: false)) : error!((Entities::Default.represent result = { error: "Internal Server Error : #{e}" }, success: false))
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error!((Entities::Default.represent e.to_h.symbolize_keys, success: false))
    end

    route :any, "*path" do
      error!((Entities::Default.represent result = { error: "Invalid route: \"#{request.path}\"" }, success: false), 404)
    end
  end
end
