require 'spec_helper'

describe PasswordResetsController do

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  it "index should redirect to new password reset path"

  describe "create" do
    it 'should send password reset if recaptcha and personal email are verified'
    it 'should redirect to root_url if recaptcha and personal email are verified'
    it 'should flash error if recaptcha or email not verified'
    it 'should flash error if recaptcha or email not verified'
    it 'should should redirect to new password reset path if recaptcha or email not verified'
  end

  describe "edit" do
    it 'should redirect to new password reset path if reset_link has expired'
    it 'should flash error if reset_link has expired'
  end

  describe "update" do

    context "success" do
      it 'should flash notice with success'
      it 'should redirect to root url'
    end

    context "password complexity not met" do
      it 'should flash error with password complexity message'
      it 'should redirect to edit_password_reset_path'
    end

    context "authentication failure" do
      it 'should flash error with server message'
      it 'should redirect to new_password_reset_path'
    end

  end

  describe "process_request" do
    it 'should contact active directory server'
  end

  describe "encode" do
      it 'should return a unicode version of password'
  end

end
