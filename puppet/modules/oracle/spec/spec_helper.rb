require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppetlabs_spec_helper/puppet_spec_helper'

require 'rspec'

# Set prepend lib's from all modules to current path
module_path = Pathname(__FILE__).parent + 'fixtures' + 'modules'
module_path.children.each  do | dir |
  lib_path = dir + 'lib'
  $:.unshift(lib_path)
end


RSpec.configure do |c|
  c.mock_with :rspec 
end

require 'easy_type'
InstancesResults = EasyType::Helpers::InstancesResults
require 'support/easy_type_shared_specs'