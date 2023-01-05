module Entities
  class GroupBasic < Grape::Entity
    self.hash_access = :to_s

    expose :id, :name, :users_count
    expose :user_joins, as: :is_joined

    private
    def initialize(group, option = {})
      @current_user_groups = option[:current_user_groups]
      super(group, option)
    end

    def user_joins
      @current_user_groups.call(object["id"]) ? true : false
    end
  end
end