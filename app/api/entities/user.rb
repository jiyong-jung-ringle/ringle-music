module Entities
  class User < Grape::Entity
    self.hash_access = :to_s
    
    expose :id, :name

    expose :email, :created_at, if: :with_full

    expose :liked_at, if: :with_like
    expose :joined_at, if: :with_join
  end
end