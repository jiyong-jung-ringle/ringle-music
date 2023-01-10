module UserService
  class GetInfo < ApplicationService
    def initialize(current_user)
      @current_user = current_user
    end

    def call
      get_user_info
    end

      private
        def get_user_info
          @current_user
        end
  end
end
