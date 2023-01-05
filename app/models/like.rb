class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likable, polymorphic: true, counter_cache: :likes_count
  validates :likable_id, uniqueness: { scope: [:user_id, :likable_type] }

  def self.toggle_like!(user:, likable:)
    like = Like.find_by(user: user, likable: likable)
    like ? like.destroy : Like.create!(user: user, likable: likable)
  end

  def self.create_like!(user:, likable:)
    like = Like.find_by(user: user, likable: likable)
    like ? nil : Like.create!(user: user, likable: likable)
  rescue => e
    nil
  end

  def self.destroy_like!(user:, likable:)
    like = Like.find_by(user: user, likable: likable)
    like ? like.destroy : nil
  rescue => e
    nil
  end
end
