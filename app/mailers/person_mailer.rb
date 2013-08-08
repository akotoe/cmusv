class PersonMailer < ActionMailer::Base
  default :from => 'CMU-SV Official Communication <help@sv.cmu.edu>',
          #:cc => 'help@sv.cmu.edu',
          #:bcc => 'todd.sedano@sv.cmu.edu',
          :subject => 'Welcome to Carnegie Mellon University Silicon Valley'

  def welcome_email(person, options = {})
    @person = person

    mail(:to => [@person.personal_email],
         :subject => options[:subject] || "Welcome to Carnegie Mellon University Silicon Valley (" + @person.email + ")",
         :date => Time.now)
    #mail :to => person.personal_email, :subject => "Whiteboard Password Reset"
  end

  def general_account_information(person, options = {})
    @person = person

    mail(:to => [@person.personal_email],
         :subject => options[:subject] || "Account information (" + @person.email + ")",
         :date => Time.now)

  end

  def twiki_created_notification(person, options={})
    @person = person
    mail(:to=>[@person.personal_email],
          :subject=>options[:subject] || "Twiki account information ("+@person.email+")",
          :date=>Time.now)
  end

  def andrew_account_created_notification(person, options={})
    @person = person
    mail(:to=>[@person.personal_email],
         :subject=>options[:subject] || "Andrew account information ("+@person.email+")",
         :date=>Time.now)
  end

  def active_directory_password_change_notification(person, options={})
    @person = person
    mail(:to=>[@person.personal_email],
         :subject=>options[:subject] || "Password change notification ("+@person.email+")",
         :date=>Time.now)
  end

end
