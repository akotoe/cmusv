class PasswordResetsController < ApplicationController
  layout 'cmu_sv'

  # Display new password reset page
  def index
    redirect_to new_password_reset_path
  end

  # Create new password reset request
  def create
    @user = User.find_by_email(params[:cmu_email])
    @active_directory_services = ActiveDirectory.new

    if verify_recaptcha(:model => @user, :attribute => "verification code")
      if @user && @user.personal_email == params[:personal_email]
        @active_directory_services.send_password_reset_token(@user)
      else
        flash[:error] = "Your email entries did not match our records. Please try again or contact help@sv.cmu.edu"
        redirect_to new_password_reset_path and return
      end
      redirect_to root_url, :notice => "Password reset instructions have been sent to #{@user.personal_email}."
    else
      flash[:error] = "Verification code is wrong"
      redirect_to new_password_reset_path
    end
  end

  # Display edit form with password reset token link
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to new_password_reset_path, :flash => {:error => "Password reset link is invalid."}
  end

  # Performs actual password reset
  def update
    @user = User.find_by_password_reset_token!(params[:id])
    @active_directory_services = ActiveDirectory.new
    respond_to do |format|
      if @user.password_reset_sent_at>2.hours.ago
        if params[:newPassword]
          if Ldap.authenticate
            message = @active_directory_services.reset_password(@user, params[:new_password])
            if message == "Success"
              if @user.active_directory_account_created_at>10.minutes.ago
                flash[:notice] = "You have successfully created your account! You can log in with your new password."
                PersonMailer.general_account_information(@user).deliver
              else
                flash[:notice] = "Your password was successfully changed! Login with your new password."
                PersonMailer.active_directory_password_change_notification(@user).deliver
              end
              format.html {redirect_to root_url}
            else
              flash[:error]="Password does not meet required minimum complexity. Read instructions below."
              redirect_to edit_password_reset_path and return
            end
          else
            flash[:error] = "Cannot contact server."
            format.html {redirect_to edit_password_reset_path}
          end
        end
      else
        flash[:error] = "Password reset link has expired #{@user.password_reset_sent_at}"+"#{2.hours.ago}"+"  #{@user.password_reset_sent_at < 2.hours.ago}"
        format.html {redirect_to new_password_reset_path}
      end
    end
  end
end
