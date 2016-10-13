unless Vagrant.has_plugin?("vagrant-vagga")
  abort 'vagrant-vagga plugin is not installed! Do first # vagrant plugin install vagrant-vagga'
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :vagga
end