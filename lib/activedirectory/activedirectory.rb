require 'net/ldap'

class Ldap

  base_dn = "ou=sync, dc=cmusv, dc=sv, dc=cmu, dc =local "

  # Configure connection parameters
  protected
  def self.configure
    conn = Net::LDAP.new
    conn.host = '10.0.0.130'
    conn.port = 636 #389
    conn.encryption(:method=>:simple_tls)
    conn.auth "username@cmusv.sv.cmu.local", "password" # Create a special account for this
    return conn
  end

  # Authenticate against active directory, time out after N seconds, return true or false
  def self.authenticate
    begin
      Timeout::timeout(10) do
        return (self.configure.bind) ? true : false
      end
    rescue Timeout::Error=>e
      return false
    end
  end

  # Search Active Directory, return results if successful, false if unsuccessful
  def self.search(email_id)
    filter = Net::LDAP::Filter.eq("mail", email_id)
    if (self.authenticate)
      self.configure.search(:base => base_dn, :filter => filter) do |entry|
        debugger.log ("DN: #{entry.dn}")
        entry.each do |attribute, values|
          puts "   #{attribute}:"
          values.each do |value|
            puts "      --->#{value}"
          end
        end
      end
    else
      return false
    end
  end
end

