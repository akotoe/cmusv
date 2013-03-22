#
#Active directory access configuration file
#

require 'net/ldap'

host = '10.0.0.130'
port = 389 # 636 is required for SSL/TLS
ad_username = "edward.akoto@cmusv.sv.cmu.local"
ad_password = "Just4now"


# Establish a connection to active directory
def active_directory_connection
  @active_directory_connection = Net::LDAP.new(:host=>host,
                       :port=>port,
                       :auth=>{
                           :method=>:simple,
                           :username=>ad_username,
                           :password=>ad_password
                       }
  )
end

