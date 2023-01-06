module Entities
  class Default < Grape::Entity
    self.hash_access = :to_s
    expose :success do |data, options|
      options[:success].nil? ? true : options[:success]
    end
    expose :data do |data, options|
      data.except!(:success)
    end
  end
end