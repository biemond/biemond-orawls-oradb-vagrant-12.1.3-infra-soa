# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "oracle"

  config.vm.provision :shell, :inline => "ln -sf /vagrant /etc/puppet/modules/oracle"
  config.vm.provision :shell, :inline => "puppet module install hajee/easy_type"

end
