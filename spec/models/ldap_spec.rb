require 'spec_helper'

describe Ldap do

  it 'can return connection to active directory'

  context 'authenticate' do
    it 'can authenticate user, returning true of successful'
    it 'can authenticate user, returning false if unsuccessful'
  end

  context 'search' do
    it 'can search user, returning key_value result'
    it 'can return false if search in unsuccessful'
  end

end
