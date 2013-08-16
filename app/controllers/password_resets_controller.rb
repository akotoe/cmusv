class PasswordResetsController < ApplicationController
  layout 'cmu_sv'

  # Display new password reset page
  def index
    redirect_to new_password_reset_path
  end

  # Display edit password page
  def show
    redirect_to edit_password_reset_path
  end

  # Create new password reset request
  def create
    @user = User.find_by_email(params[:cmu_email])
    @active_directory_services = ActiveDirectory.new

    if verify_recaptcha(:model => @user, :attribute => "verification code")
      if @user && @user.personal_email == params[:personal_email]
        @active_directory_services.send_password_reset_token(@user)
        redirect_to root_url, :notice => "Password reset instructions have been sent to #{@user.personal_email}"
      else
        flash[:error] = "Your email entries do not match our records. Please try again or contact help@sv.cmu.edu"
        redirect_to new_password_reset_path and return
      end
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
    respond_to do |format|
      if @user && !@user.password_reset_sent_at.nil? && @user.password_reset_sent_at>2.hours.ago # If request was sent within two hours
        @active_directory_services = ActiveDirectory.new
        if params[:new_password]
          message = @active_directory_services.reset_password(@user, params[:new_password])

          if message == "Success"
            if !@user.active_directory_account_created_at.nil? && @user.active_directory_account_created_at>10.minutes.ago
              flash[:notice] = "You have successfully created your account! You can log in with your new password."
              PersonMailer.general_account_information(@user).deliver
            else
              flash[:notice] = "Your password was successfully changed! Login with your new password."
              PersonMailer.active_directory_password_change_notification(@user).deliver
            end
            format.html {redirect_to root_url}

          elsif message.is_a?(String)
            # Alert help@sv.cmu.edu
            options = {:to => "test.whiteboard@sv.cmu.edu", :cc => "", :subject => "AD Error: #{@user.email}",
                       :message => "LDAP Error code: #{message}", :url => "", :url_label => ""}
            GenericMailer.email(options).deliver

            if message== "Unwilling to perform"
              flash[:error]="Password does not meet required minimum complexity. Read instructions below or report to help@sv.cmu.edu."
            else
              flash[:error]="Sorry your request cannot be completed at the moment. We have notified help@sv.cmu.edu."
            end
            redirect_to edit_password_reset_path and return
          else
            # Alert help@sv.cmu.edu
            options = {:to => "test.whiteboard@sv.cmu.edu", :cc => "", :subject => "AD Error: #{@user.email}",
                       :message => "LDAP Error code: Unable to authenticate or bind to Active Directory server.", :url => "", :url_label => ""}
            GenericMailer.email(options).deliver

            flash[:error] = "Sorry your request cannot be completed at the moment. We have notified help@sv.cmu.edu."
            redirect_to edit_password_reset_path and return
          end

        else
          flash[:error]="New password cannot be empty. Try again."
          redirect_to edit_password_reset_path and return
        end
      else
        flash[:error] = "Password reset link has expired. You may send a new link."
        redirect_to redirect_to new_password_reset_path and return
      end
    end
  end
end
