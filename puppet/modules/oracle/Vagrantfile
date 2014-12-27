# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hajee/centos-5.8-oracle11"

  config.vm.provision :shell, :inline => "puppet module install hajee-easy_type"
  config.vm.provision :shell, :inline => "rm -rf /etc/puppet/modules/oracle; ln -s /vagrant /etc/puppet/modules/oracle"
end
