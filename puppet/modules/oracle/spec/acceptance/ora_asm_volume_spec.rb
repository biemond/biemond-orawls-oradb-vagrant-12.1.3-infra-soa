require_relative '../spec_helper_acceptance'
require_relative '../support/shared_acceptance_specs'


describe 'ora_asm_volume' do

  # it_behaves_like "an ensurable resource", {
  #   :resource_name      => 'ora_service',
  #   :present_manifest   => "ora_service{my_test: ensure=>'present'}",
  #   :absent_manifest    => "ora_service{my_test: ensure=>'absent'}"
    #TODO: We should be able to delete the service. Registerd as issue #32
  # }
  it "should tested. " do
    skip "Until we get grid installed on SUT"
  end
end
