class PersonJob < Struct.new(:person_id, :create_twiki_account)
  def perform
#    Delayed::Worker.logger.debug("person_id #{person_id}, create_google_email #{create_google_email}, create_twiki_account #{create_google_email}")

    person = Person.find(person_id)
    error_message = ""
    if create_twiki_account && person.twiki_created.blank?
      status = person.create_twiki_account
      error_message +=  "TWiki account #{person.twiki_name} was not created.<br/><br/>" unless status
      status = person.reset_twiki_password
      error_message +=  'TWiki account password was not reset.<br/>' unless status
    end

    if(!error_message.blank?)
      Delayed::Worker.logger.debug(error_message)
      puts error_message
      message = error_message
      GenericMailer.email(
          :to => ["edward.akoto@sv.cmu.edu", "albert.liu@sv.cmu.edu"],
          :from => "test.whiteboard@sv.cmu.edu",
          :subject => "PersonJob had an error on person id = #{person.id}",
          :message => message,
          :url_label => "Show which person",
          :url => "http://whiteboard.sv.cmu.edu/people/#{person.id}" #+ person_path(person)
      ).deliver
    end
  end
end
