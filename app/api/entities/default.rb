module Entities
  class Default < Grape::Entity
    self.hash_access = :to_s
    expose :success, if: :success, default: true
    expose :data do |data, options|
      data.except!(:success)
    end
  end
end