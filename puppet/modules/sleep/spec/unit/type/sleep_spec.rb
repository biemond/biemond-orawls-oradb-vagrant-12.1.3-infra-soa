require 'puppet'
require 'spec_helper'
describe Puppet::Type.type(:sleep) do
  subject { Puppet::Type.type(:sleep).new(:name => 5) }

end
