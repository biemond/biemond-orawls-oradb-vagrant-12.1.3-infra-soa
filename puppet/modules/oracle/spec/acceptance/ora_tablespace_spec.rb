require_relative '../spec_helper_acceptance'
require_relative '../support/shared_acceptance_specs'


describe 'ora_tablespace' do

  it_behaves_like "an ensurable resource", {
    :resource_name      => 'ora_tablespace',
    :present_manifest   => <<-EOS,

    ora_tablespace{test: 
      ensure    =>'present',
      datafile  => 'test.dbf', 
      logging   =>'yes', 
      size      => '5M',
    }

    EOS
    :change_manifest   => <<-EOS,

    ora_tablespace{test: 
      ensure    =>'present',
      datafile  => 'test.dbf', 
      logging   =>'no', 
      size      => '5M',
    }

    EOS
    :absent_manifest    => <<-EOS,
    ora_tablespace{test: 
      ensure    =>'absent',
    }
    EOS
  }
end
