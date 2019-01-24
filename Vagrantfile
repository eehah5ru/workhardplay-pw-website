# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # config.vm.box = "puppetlabs/debian-7.8-64-nocm"
  config.vm.box = "ubuntu/trusty64"
  
  # config.vm.synced_folder ENV['STACK_BUILD_DIR'], "/vagrant-build", type: "rsync", rsync__verbose: true, rsync__exclude: [".stack-work/", "_release/", ".cabal-sandbox/", "cabal.sandbox.config", "dist/", ".#*#", "*.vdi", "*.vmdk", "*.raw", ".DS_Store"], rsync__args: ["--verbose", "--archive", "--delete", "-z"]

  # config.vm.synced_folder "../../..", "/vagrant", type: "rsync", rsync__verbose: true, rsync__exclude: [".stack-work/", "_release/", ".cabal-sandbox/", "cabal.sandbox.config", "dist/", ".#*#", "*.vdi", "*.vmdk", "*.raw", ".DS_Store"], rsync__args: ["--verbose", "--archive", "--delete", "-z"]

  config.vm.synced_folder ".", '/home/vagrant/whph-website', :owner => "vagrant"

  config.vm.synced_folder "provisioning", '/vagrant'

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end
  
  config.ssh.forward_agent = true

  config.vm.hostname = "whph-stack"
  
  config.vm.provision "shell", path: "provisioning/prelude.sh"
  config.vm.provision "shell", privileged: false, path: "provisioning/user-specific.sh"
  config.vm.provision "shell", path: "provisioning/whph-setup.sh", privileged: false
end
