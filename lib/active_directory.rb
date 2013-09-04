require 'net/ldap'

# Domain of the Active Directory Server
AD_DOMAIN = ENV['AD_DOMAIN'] || "ds.sv.cmu.edu"

# This class provides active directory services
class ActiveDirectory

  # Initialize connection to active directory
  def initialize
    # Establish connection
    @connection = Net::LDAP.new(:host => LDAPConfig.host, :port => LDAPConfig.port)
    @connection.encryption(:method => :simple_tls) unless !LDAPConfig.is_encrypted?
    @connection.auth LDAPConfig.username, LDAPConfig.password unless LDAPConfig.username.nil? || LDAPConfig.password.nil?

    # Update organization units
    update_organization_units
  end

  # Create an Active Directory account for a user
  # Error out if user's email address is blank or domain is not Google domain
  # If this fails, return an error message as a string, else return void
  # The return message is "Success", "Unwilling to perform", "Entry Already Exists", "No such object", "Unable to authenticate...", "True"
  def create_account(user)
    return "Empty email address. Edit your profile page" if user.email.blank?

    domain = user.email.split('@')[1]
    if domain.nil? || domain!= GOOGLE_DOMAIN
      return "Domain (" + domain + ") is not the same as the google domain (" + GOOGLE_DOMAIN + ")"
    end

    if bind
      @connection.add(:dn => ldap_distinguished_name(user), :attributes => ldap_attributes(user))
      message = @connection.get_operation_result.message
      if message == "Success" || message == "Entry Already Exists"
        user.active_directory_account_created_at = Time.now()
        user.save
      end
      return message

    else
      return "Unable to authenticate or bind to Active Directory server."
    end
  end

  # Attempt to bind to active directory, time out after N seconds, return true or false
  def bind
    return false unless !@connection.nil?
    begin
      Timeout::timeout(10) do
        return (@connection.bind) ? true : false
      end
    rescue
      return false
    end
  end

  # Build attributes for active directory account
  # Code 512 creates standard user account and enables it
  def ldap_attributes(user)
    attributes = {
        :cn => user.human_name,
        :mail => user.email,
        :objectclass => ["top", "person", "organizationalPerson", "user"],
        :userPrincipalName => format_email_to_ad_domain(user.email),
        :unicodePwd => password_encode('Just4now' + Time.now.to_f.to_s[-4, 4]),
        :userAccountControl => "512",
        :sn => user.last_name,
        :givenName => user.first_name,
        :displayName => user.human_name
    }
    return attributes
  end

  # Build user distinguished name for active directory account
  def ldap_distinguished_name(user)
    distinguished_name = "cn=#{user.human_name},"

    if user.is_staff
      if !user.masters_program.blank? && organization_units.include?(user.masters_program)
        distinguished_name += "ou=" + user.masters_program + ",ou=Staff,"
      else
        distinguished_name += "ou=Staff,"
      end
    elsif user.is_student
      if !user.masters_program.blank? && organization_units.include?(user.masters_program)
        distinguished_name += "ou=" + user.masters_program + ",ou=Student,"
      else
        distinguished_name += "ou=Student,"
      end
    end

    distinguished_name +="ou=Sync,"+base_distinguished_name
    return distinguished_name
  end

  # Create base distinguished name from the active directory domain name
  def base_distinguished_name
    base_name = ""
    AD_DOMAIN.split('.').each do |item|
      base_name+="dc=#{item},"
    end
    base_name.chop
  end

  # Convert password to unicode format
  def password_encode(password)
    result = ""
    password = "\"" + password + "\""
    password.length.times { |i| result+= "#{password[i..i]}\000" }
    return result
  end

  # Send active directory password reset token
  def send_password_reset_token(user)
    user.set_password_reset_token
    user.password_reset_sent_at = Time.zone.now
    user.save!
    PasswordMailer.password_reset(user).deliver
  end

  # Reset active directory password
  def reset_password(user, new_pass)
    if bind
      distinguished_name = ldap_distinguished_name(user)
      @connection.replace_attribute distinguished_name, :unicodePwd, password_encode(new_pass)
      return @connection.get_operation_result.message
    else
      return false
    end
  end

  # Format email with a active directory domain
  def format_email_to_ad_domain(email)
    return "#{email.split('@')[0]}@#{AD_DOMAIN}"
  end

  # Return names of organization units
  def organization_units
    if bind
      units = []
      AdOrganizationUnit.find_each do |local_entry|
        name = local_entry.distinguishedname.split(',')[0]
        units.push(name[3..name.length])
      end
      return units
    else
      return false
    end
  end

  # Update organization units cache table if records are more than one day old
  def update_organization_units

    oldest_update = AdOrganizationUnit.order('created_at').last

    if bind && (oldest_update.nil? || oldest_update.created_at<1.day.ago)
      filter = Net::LDAP::Filter.eq("objectClass", "organizationalunit")
      results = @connection.search(:base =>"ou=Sync,"+base_distinguished_name, :filter => filter)
      remote_organization_units = Hash.new
      local_organization_units = Hash.new

      # Build hash for local entries
      AdOrganizationUnit.find_each do |local_entry|
        local_organization_units[local_entry.distinguishedname] = local_entry.whenchanged
      end

      # Add new entries to local database
      results.each do |remote_entry|
        # Build hash for remote entries
        remote_organization_units[remote_entry.distinguishedname[0]] = remote_entry.whenchanged[0]
        if !local_organization_units.has_key?(remote_entry.distinguishedname[0])
          new_organization_unit = AdOrganizationUnit.new
          new_organization_unit.distinguishedname = remote_entry.distinguishedname[0]
          new_organization_unit.whenchanged = remote_entry.whenchanged[0]
          new_organization_unit.save!
        end
      end

      # Remove old entries from local database
      local_organization_units.each do |local_entry|
        if !remote_organization_units.has_key?(local_entry[0])
          AdOrganizationUnit.find_by_distinguishedname(local_entry[0]).destroy
        end
      end
    else
      return false
    end
  end

end

