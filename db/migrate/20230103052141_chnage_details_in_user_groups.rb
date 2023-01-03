class ChnageDetailsInUserGroups < ActiveRecord::Migration[7.0]
  def change
    change_column_null :user_groups, :user_id, true
    change_column_null :user_groups, :group_id, true
  end
end
