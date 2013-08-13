class PersonMailer < ActionMailer::Base
  default :from => 'CMU-SV Official Communication <help@sv.cmu.edu>',
          :cc => 'help@sv.cmu.edu',
          :bcc => "rails.app@sv.cmu.edu",
          :subject => 'Welcome to Carnegie Mellon University Silicon Valley'


  # Send general welcome information when a new account is initiated
  # Send a link to new user for completing account creation process
  def welcome_email(person, options = {})
    @person = person
    @host = ENV['HOST_NAME'] || "localhost:3000"

    mail(:to => [@person.personal_email],
         :subject => options[:subject] || "Welcome to Carnegie Mellon University Silicon Valley (" + @person.email + ")",
         :date => Time.now)

  end

  # Send general information about various accounts once the user completes account creation process
  def general_account_information(person, options = {})
    @person = person

    mail(:to => [@person.personal_email],
         :subject => options[:subject] || "Account information (" + @person.email + ")",
         :date => Time.now)

  end

  # Send twiki account information
  def twiki_created_notification(person, options={})
    @person = person
    mail(:to=>[@person.personal_email],
          :subject=>options[:subject] || "Twiki account information ("+@person.email+")",
          :date=>Time.now)
  end

  # Send Andrews account information
  def andrew_account_created_notification(person, options={})
    @person = person
    mail(:to=>[@person.personal_email],
         :subject=>options[:subject] || "Andrew account information ("+@person.email+")",
         :date=>Time.now)
  end

  # Send active directory password change information
  def active_directory_password_change_notification(person, options={})
    @person = person
    mail(:to=>[@person.personal_email],
         :subject=>options[:subject] || "Password change notification ("+@person.email+")",
         :date=>Time.now)
  end

end
