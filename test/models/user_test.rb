require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should reject empty username' do
    @user = User.new password: 'abcdefgh',
                     password_confirmation: 'abcdefgh'
    assert_not @user.save, 'Saved a user without username'
  end

  test 'should reject empty password' do
    @user = User.new username: 'test_user'
    assert_not @user.save, 'Saved a user without password'
  end

  test 'should reject short password' do
    @user = User.new username: 'test_user',
                     password: 'short',
                     password_confirmation: 'short'
    assert_not @user.save, 'Saved a user with short password "short"'
  end

  test 'should reject password mismatch' do
    @user = User.new username: 'test_user',
                     password: 'abcdefgh',
                     password_confirmation: 'abcdefghi'
    assert_not @user.save, 'Saved a user with mismatched password "abcdefgh" and confirmation "abcdefghi"'
  end

  test 'should accept valid users' do
    @user = User.new username: 'valid_user',
                     password: 'good password',
                     password_confirmation: 'good password'
    assert @user.save, 'Rejected valid user "valid_user" with password "good password"'
  end

  test 'should reject duplicate username' do
    @user = User.new username: 'duplicate_username',
                     password: 'valid password',
                     password_confirmation: 'valid password'
    @user.save!

    @user = User.new username: 'duplicate_username',
                     password: 'another valid password',
                     password_confirmation: 'another valid password'
    assert_not @user.save, 'Saved users with duplicate username "duplicate_username"'
  end

  test 'should assign unapproved permission to newly created users' do
    @user = User.new username: 'new_user',
                     password: 'good password',
                     password_confirmation: 'good password'
    @user.save!

    assert @user.unapproved?, 'Automatically approved a new user'
  end

  test 'should not authorize users with insufficient permission' do
    @user = User.new username: 'member_user',
                     password: 'good password',
                     password_confirmation: 'good password'
    @user.save!

    assert_not @user.permission?(:reviewer), 'Authorized a member as a reviewer'
    assert_not @user.permission?(:admin), 'Authorized a member as an admin'
    assert_not @user.permission?(:developer), 'Authorized a member as a developer'
  end

  test 'should authorize users with appropriate permission' do
    @user = User.new username: 'admin_user',
                     password: 'good password',
                     password_confirmation: 'good password'
    @user.save!
    @user.update_permission! :admin

    assert @user.permission?(:reviewer), 'Rejected authorization of an admin as a reviewer'
    assert @user.permission?(:admin), 'Rejected authorization of an admin as an admin'
    assert_not @user.permission?(:developer), 'Authorized an admin as a developer'
  end
end
