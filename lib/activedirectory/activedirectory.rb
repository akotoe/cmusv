require 'net/ldap'

# This class establishes an encrypted connection to active directory, and authenticates users against active directory.
class Ldap

  # Configure parameters for an encrypted connection to LDAP server
  def self.configure

    ad_host = "10.0.0.130"
    ad_user = "edward.akoto@cmusv.sv.cmu.local"
    ad_password = "Just4now"

    conn = Net::LDAP.new
    conn.host = ad_host #LDAP host
    conn.port = 636 # 636 for SSL, 389 for non-SSL
    conn.encryption(:method=>:simple_tls)
    conn.auth ad_user, ad_password # Create a special account for this
    return conn
  end

  # Authenticate against active directory, time out after N seconds, return true or false
  def self.authenticate
    begin
      Timeout::timeout(10) do
        return (self.configure.bind) ? true : false
      end
    rescue Timeout::Error
      return false
    end
  end
end

