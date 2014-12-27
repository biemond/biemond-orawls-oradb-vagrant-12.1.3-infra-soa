require_relative '../spec_helper_acceptance'
require_relative '../support/shared_acceptance_specs'


describe 'ora_user' do

  it_behaves_like "an ensurable resource", {
    :resource_name      => 'ora_user',
    :present_manifest   => "ora_user{test: ensure=>'present', default_tablespace=>'SYSTEM'}",
    :change_manifest    => "ora_user{test: ensure=>'present', default_tablespace=>'USERS'}",
    :absent_manifest    => "ora_user{test: ensure=>'absent'}",
  }

end
