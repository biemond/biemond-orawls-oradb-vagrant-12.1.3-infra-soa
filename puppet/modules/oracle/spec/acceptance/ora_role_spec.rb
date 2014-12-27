require_relative '../spec_helper_acceptance'
require_relative '../support/shared_acceptance_specs'

describe 'ora_role' do

  it_behaves_like "an ensurable resource", {
    :resource_name      => 'ora_role',
    :present_manifest   => "ora_role{test: ensure=>'present'}",
    :absent_manifest    => "ora_role{test: ensure=>'absent'}",
  }
end
