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

  def account_complete(person, options = {})
    @person = person

    mail(:to => [@person.personal_email],
         :subject => options[:subject] || "Account information (" + @person.email + ")",
         :date => Time.now)

  end

end
