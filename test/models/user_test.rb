require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @User = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @User.valid?
  end

  test "name should not be present" do
    @User.name = ""
    assert_not @User.valid?
  end

  test "email should not be present" do
    @User.email = ""
    assert_not @User.valid?
  end

  test "name should not be too long" do
    @User.name = "a" * 51
    assert_not @User.valid?
  end

  test "email should not be too long" do
    @User.email = "a" * 244 + "@example.com"
    assert_not @User.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @User.email = valid_address
      assert @User.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @User.email = invalid_address
      assert_not @User.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
    duplicate_user = @User.dup
    @User.save
    assert_not duplicate_user.valid?
  end

  test "emails should be lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @User.email = mixed_case_email
    @User.save
    assert_equal mixed_case_email.downcase, @User.reload.email
  end

  test "password should be present (nonblank)" do
    @User.password = @User.password_confirmation = " " * 6
    assert_not @User.valid?
  end

  test "password should have a minimum length" do
    @User.password = @User.password_confirmation = "a" * 5
    assert_not @User.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @User.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @User.save
    @User.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @User.destroy
    end
  end
end
