require_relative '../spec_helper_acceptance'
require_relative '../support/shared_acceptance_specs'


describe 'ora_init_param' do

  context "SPFILE for current node" do
    it_behaves_like "an ensurable resource", {
      :resource_name      => 'ora_init_param',
      :present_manifest   => <<-EOS,
        ora_init_param { 'spfile/tracefile_identifier:*@test':
          ensure => 'present',
          value  => 'first_one',
        }
      EOS
      :change_manifest    => <<-EOS,
        ora_init_param { 'spfile/tracefile_identifier:*@test':
          ensure => 'present',
          value  => 'and_changed',
        }
      EOS
      :absent_manifest    => <<-EOS
        ora_init_param { 'spfile/tracefile_identifier:*@test':
          ensure => 'absent',
        }
      EOS
    }
  end

  context "MEMORY for current node" do
    it_behaves_like "an ensurable resource", {
      :resource_name      => 'ora_init_param',
      :present_manifest   => <<-EOS,
        ora_init_param { 'memory/control_file_record_keep_time:*@test':
          ensure => 'present',
          value  => '20',
        }
      EOS
      :change_manifest    => <<-EOS
        ora_init_param { 'memory/control_file_record_keep_time:*@test':
          ensure => 'present',
          value  => '10',
        }
      EOS
    }
  end


end
