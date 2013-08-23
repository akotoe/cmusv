# Use this mailer to send notifications to support
class SupportMailer < ActionMailer::Base
  default :from => "whiteboard-noreply@#{GOOGLE_DOMAIN}",
          :to => "edward.akoto@sv.cmu.edu",
          :cc => "albert.liu@ad.sv.cmu.edu"

  # Notify support about failure
  def failure_notification(message = "")
    @message = message
    mail :subject => "Whiteboard failure notification"
  end

  # Notify support about success
  def success_notification(message="")
    @message = message
    mail :subject => "Whiteboard success notification"
  end

end
