require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end
  
  def test_should_require_unique_login
    existing_user = users(:quentin)
    assert_no_difference User, :count do 
      u = create_user(:login => existing_user.login)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end
  
  def test_invalid_with_identity_url_but_no_login
    user = User.new(:identity_url => 'http://some.where.com/')
    assert !user.valid?, "User has no login, should be invalid"
  end

  def test_invalid_with_identity_url_but_duplicate_login
    existing_user = users(:quentin)
    user = User.new(:identity_url => 'http://some.where.com/', :login => existing_user.login)
    assert !user.valid?, "User has duplicate login, should be invalid"
  end
  
  def test_identity_url_becomes_user_openid_on_create
    params = { :login => 'foobar', :email => 'foo@bar.com', :name => 'Foo Bar', :identity_url => 'http://foobar.com/' }
    assert_difference User, :count, 1 do 
      assert_difference UserOpenid, :count, 1 do 
        user = User.create(params)
        assert_equal(params[:email], user.email)
        assert_equal(params[:name],  user.name)
        assert_equal(1, user.user_openids.count)
        user_openid = user.user_openids.first
        assert_equal(params[:identity_url], user_openid.openid_url)
      end
    end
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
