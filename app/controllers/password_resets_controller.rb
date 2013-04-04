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
    @user = User.find_by_email(params[:primaryEmail])
    if verify_recaptcha(:model=>@user,:message=>"Verification code is wrong", :attribute=>"verification code")
      if @user && @user.personal_email == params[:personalEmail]
        @user.send_password_reset
      end
      redirect_to root_url, :notice => "<div align='center'><b>Request sent!</b><br/> You will receive an email with password reset instructions if matching records are found. <br/></div>".html_safe
    else
      flash[:error] = "Verification code is wrong"
      redirect_to new_password_reset_path
    end

  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to new_password_reset_path, :flash => { :error => "Password reset link has expired" }
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    respond_to do |format|
      if @user.password_reset_sent_at<2.hours.ago
        if params[:newPassword]
          if Ldap.authenticate
            message = process_request(@user, params[:newPassword])
            if message == "Success"
              flash[:notice] = "Password has been reset!"
              format.html {redirect_to root_url}
            else
              flash[:error]="Password does not meet required minimum complexity. Ensure to have a digit, a capital, and a minimum of eight characters."
              redirect_to edit_password_reset_path and return
            end
          else
            flash[:error] = "Cannot contact server."
            format.html {redirect_to edit_password_reset_path}
          end
        end
      else
        flash[:error] = "Password reset link has expired"
        format.html {redirect_to new_password_reset_path}
      end
    end
  end

  # Transact against active directory
  def process_request(user, new_pass)
    dn = user.get_dn

    # Establish connection
    con = Ldap.configure

    # Reset password
    logger.debug("Resetting password" )
    con.replace_attribute dn, :unicodePwd, encode(new_pass)

    # Build response
    message = con.get_operation_result.message
    logger.debug(message)
    message
  end

  # Create unicode password
  def encode(pwd)
    ret = ""
    pwd = "\"" + pwd + "\""
    pwd.length.times{|i| ret+= "#{pwd[i..i]}\000" }
    ret
  end
end
