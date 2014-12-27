require_relative '../spec_helper_acceptance'
require_relative '../support/shared_acceptance_specs'


describe 'ora_service' do

  it_behaves_like "an ensurable resource", {
    :resource_name      => 'ora_service',
    :present_manifest   => "ora_service{my_test_service: ensure=>'present'}",
    :absent_manifest    => "ora_service{my_test_service: ensure=>'absent'}"
  }
end
