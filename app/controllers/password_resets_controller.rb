class PasswordResetsController < ApplicationController
  layout 'cmu_sv'
  require 'activedirectory/activedirectory'

  def index
    redirect_to new_password_reset_path
  end

  def new
    # Displays new page
  end

  def create
    @user = User.find_by_email(params[:email])
    if verify_recaptcha(:model=>@user,:message=>"Verification code is wrong", :attribute=>"verification code")
      @user.send_password_reset if @user
      redirect_to new_password_reset_path, :notice => "Email sent with password reset instructions"
    else
      flash[:error] = "Verification code is wrong"
      redirect_to new_password_reset_path
    end

  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at<2.hours.ago
      redirect_to password_reset_path, :alert => "Password reset has expired"
    elsif Ldap.authenticate
      if params[:newPassword]
        process_request(@user, params[:newPassword])
        flash[:notice] = "Successful "
      end
      redirect_to new_password_reset_path


    else
      flash[:error] = "Unsuccessful "
      redirect_to new_password_reset_path
    end
  end

  # Transact against active directory
  def process_request(user, new_pass)
    # Build dn
    # Replace this with actual user dn
    #dn = "cn=June Bobby, ou=SE, ou=Students, ou=Sync, dc=cmusv, dc=sv, dc=cmu,dc=local"
    dn = user.get_dn

    # Establish connection
    con = Ldap.configure

    # Reset password
    logger.debug("Resetting password" )
    con.replace_attribute dn, :unicodePwd, encode(new_pass)
    logger.debug(con.get_operation_result )
  end

  # Create unicode password
  def encode(pwd)
    ret = ''
    "\"#{pwd}\"".length.times {|i| ret+= "#{pwd[i..i]}\000"}
    ret
  end
end
