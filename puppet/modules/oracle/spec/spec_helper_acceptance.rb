require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do |host|
  # Install Puppet
  install_puppet
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies

    puppet_module_install(:source => proj_root, :module_name => 'oracle')
    oracle_base_install = <<-EOS

puppetDownloadMntPoint = "puppet:///modules/oradb/"

oradb::installdb{ '12.1.0.1_Linux-x86-64':
  version                => '12.1.0.1',
  file                   => 'linuxamd64_12c_database',
  databaseType           => 'EE',
  oracleBase             => '/oracle',
  oracleHome             => '/oracle/product/12.1/db',
  createUser             => true,
  user                   => 'oracle',
  group                  => 'dba',
  downloadDir            => '/data/install',
  zipExtract             => true,
  puppetDownloadMntPoint => $puppetDownloadMntPoint,
}
    EOS
    apply_manifest(pp,:catch_failures => true)


    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs/stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'biemond/oradb'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'hajee/easy_type'), { :acceptable_exit_codes => [0,1] }


    end
  end
end
