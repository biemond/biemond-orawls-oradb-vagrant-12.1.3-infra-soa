require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'


unless ENV['RS_PROVISION'] == 'no'
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }

  if default.is_pe?; then install_pe; else install_puppet( foss_opts ); end

  hosts.each do |host|
    if host['platform'] =~ /debian/
      on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
    end

    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

UNSUPPORTED_PLATFORMS = ['Ubuntu','windows','AIX']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation
  c.order     = :defined

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies

    copy_module_to(master, :source => proj_root, :module_name => 'oracle')
    # Required for mod_passenger tests.


    unless ENV['BEAKER_provision'] == 'no'
      modules = [
        'hajee-easy_type',
        'biemond-oradb',
        'erwbgy-limits',
        'fiddyspence-sysctl',
        'puppetlabs-stdlib',
      ]

      modules.each do  |module_name |
        on(default, puppet('module', 'install', module_name), :acceptable_exit_codes => [0,1] )
      end

      scp_to default, "#{proj_root}/spec/software", '/software'
      manifest = File.read("#{proj_root}/spec/acceptance/manifests/database.pp")
      apply_manifest manifest, { :catch_failures => true }
    end

  end
end
