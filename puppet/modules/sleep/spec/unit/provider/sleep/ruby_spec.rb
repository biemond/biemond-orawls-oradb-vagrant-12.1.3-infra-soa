require 'puppet'
require 'fileutils'
require 'mocha'
RSpec.configure do |c|
  c.mock_with :mocha
end

describe 'The sleep provider for the sleep type' do
  subject { Puppet::Type.type(:sleep).provider(:linux).new(resource) }

end
