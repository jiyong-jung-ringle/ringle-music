module GroupService
  class ChangeGroupName < ApplicationService
    def initialize(current_user, group, name)
      @current_user = current_user
      @name = name
      @group = group
    end

    def call
      do_action
    end

      private
        def do_action
          @group.change_name!(name: @name)
        end
  end
end
