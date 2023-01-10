class User < ApplicationRecord
  has_many :user_groups, dependent: :destroy

  has_many :groups, through: :user_groups
  has_one :playlist, as: :ownable, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :music_playlists

  validates_uniqueness_of :email
  validates :name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  has_secure_password

  after_create UserCallbacks
  searchkick

  def self.create_user!(name:, email:, password:)
    self.lock
    self.create!(name: name, email: email, password: password)
  rescue => e
    nil
  end

  def delete_user!
    self.destroy
  end

  def change_name!(name:)
    self.update!(name: name)
    true
  rescue => e
    false
  end

  def change_password!(password:)
    return false if self.authenticate(password)
    begin
      self.update!(password: password)
      true
  rescue => e
    false
    end
  end
end
