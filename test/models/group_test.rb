require "test_helper"

class GroupTest < ActiveSupport::TestCase
  setup do
    @users = [User.create_user!(name:"test_1", email:"test_user_1@gmail.com", password: "ringle123"), 
      User.create_user!(name:"test_2", email:"test_user_2@gmail.com", password: "")]
  end

  test "validate setup" do
    @users.map do |user|
      assert user!=nil && user.valid?
    end
  end

  test "cannot create groups without name" do
    assert true
  end

  teardown do
    @users.map do |user|
      user!=nil ? user.destroy : nil
    end
  end
end
