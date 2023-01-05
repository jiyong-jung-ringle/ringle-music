class Group < ApplicationRecord
    has_many :user_groups, dependent: :destroy

    has_many :users, through: :user_groups
    has_one :playlist, as: :ownable, dependent: :destroy 
    validates :name, presence: true

    after_create GroupCallbacks

    def self.create_group!(name:, users:)
        begin
            Group.create!(name: name, users: users)
        rescue => e
            nil
        end
    end

    def delete_group!
        self.destroy
    end

    def change_name!(name:)
        begin
            self.update!(name: name)
            true
        rescue => e
            false
        end
    end

    def append_users!(users:)
        self.users << users
    end

    def append_user!(user:)
        self.append_users!(users: [user])
    end

    def delete_users!(user_ids:)
        user_groups = self.user_groups.where(user_id: user_ids)
        deleted_user_ids = self.users.where(id: user_ids).ids
        return false unless user_groups.exists?
        Group.transaction do
            user_groups.destroy_all
            self.delete_group! if self.users_count <= 0
        end
        return deleted_user_ids
    end

    def delete_user!(user_id:)
        self.delete_users!(user_ids: [user_id])
    end

    def include_user?(user:)
        self.users.include?(user)
    end
end
