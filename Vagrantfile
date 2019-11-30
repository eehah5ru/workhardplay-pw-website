# -*- mode: ruby -*-
# vi: set ft=ruby :

# Listen >=2.8 patch to silence duplicate directory errors. USE AT YOUR OWN RISK
require 'listen/record/symlink_detector'
module Listen
  class Record
    class SymlinkDetector
      def _fail(_, _)
        fail Error, "Don't watch locally-symlinked directory twice"
      end
    end
  end
end

Vagrant.configure(2) do |config|
  config.vm.define "master" do |master|
    # config.vm.box = "puppetlabs/debian-7.8-64-nocm"
    master.vm.box = "ubuntu/trusty64"

    # #
    # #
    # # unison config
    # #
    # #
    # master.unison.host_folder = "./"  #relative to the folder your Vagrantfile is in
    # master.unison.guest_folder = "whph-website/" #relative to the vagrant home folder (e.g. /home/vagrant)

    # # Optional configs
    # # File patterns to ignore when syncing. Ensure you don't have spaces between the commas!
    # master.unison.ignore = "Name {.DS_Store,_site,_cache,_tmp}" # Default: none

    # # SSH connection details for Vagrant to communicate with VM.
    # # master.unison.ssh_host = "10.0.0.1" # Default: '127.0.0.1'
    # # master.unison.ssh_port = 22 # Default: 2222
    # # master.unison.ssh_user = "deploy" # Default: 'vagrant'
    # # master.unison.perms = 0 # if you get "properties changed on both sides" error

    # # `vagrant unison-sync-polling` command will restart unison in VM if memory
    # # usage gets above this threshold (in MB).
    # master.unison.mem_cap_mb = 200 # Default: 200

    # # Change polling interval (in seconds) at which to sync changes
    # master.unison.repeat = 5 # Default: 1

    # #
    # # end of unison
    # #

    master.vm.synced_folder "provisioning", '/vagrant'

    master.vm.synced_folder ".",
                            "/home/vagrant/whph-website",
                            type: "rsync",
                            :rsync__args => ["--verbose", "--archive", "--delete", "-z", "--links", "--no-owner", "--no-group"],
                            rsync__exclude: ['.stack-work', '_cache', '_site', "_tmp", "w7w"]

    master.vm.synced_folder "w7w",
                            "/home/vagrant/whph-website/w7w",
                            type: "rsync",
                            :rsync__args => ["--verbose", "--archive", "--delete", "-z", "--links", "--no-owner", "--no-group"]
                            # rsync__exclude: ['.stack-work', '_cache', '_site', "_tmp", "src"]    
    

    master.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.name ="master"
     vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end

    master.ssh.forward_agent = true

    master.vm.hostname = "whph-master"

    master.vm.provision "file", source: ".ruby-version", destination: "~/tmp-whph-website/.ruby-version"
    master.vm.provision "file", source: ".nvmrc", destination: "~/tmp-whph-website/.nvmrc"

    master.vm.provision "shell",
                        path: "provisioning/prelude.sh",
                        privileged: true

    master.vm.provision :host_shell do |host_shell|
      host_shell.inline = 'vagrant unison-sync-once'
    end

    master.vm.provision "shell", privileged: false, path: "provisioning/user-specific.sh"
    master.vm.provision "shell", path: "provisioning/whph-common-setup.sh", privileged: false
    master.vm.provision "shell", path: "provisioning/whph-master-setup.sh", privileged: false

  end

  #
  #
  # SLAVE
  #
  #
  config.vm.define "slave" do |slave|
    # slave.vm.box = "puppetlabs/debian-7.8-64-nocm"
    slave.vm.box = "ubuntu/trusty64"

    #
    #
    # unison config
    #
    #
    # slave.unison.host_folder = "./"  #relative to the folder your Vagrantfile is in
    # slave.unison.guest_folder = "whph-website/" #relative to the vagrant home folder (e.g. /home/vagrant)

    # # Optional configs
    # # File patterns to ignore when syncing. Ensure you don't have spaces between the commas!
    # slave.unison.ignore = "Name {.DS_Store,_site,_cache,_tmp}" # Default: none

    # # SSH connection details for Vagrant to communicate with VM.
    # # slave.unison.ssh_host = "10.0.0.1" # Default: '127.0.0.1'
    # # slave.unison.ssh_port = 22 # Default: 2222
    # # slave.unison.ssh_user = "deploy" # Default: 'vagrant'
    # # slave.unison.perms = 0 # if you get "properties changed on both sides" error

    # # `vagrant unison-sync-polling` command will restart unison in VM if memory
    # # usage gets above this threshold (in MB).
    # slave.unison.mem_cap_mb = 200 # Default: 200

    # # Change polling interval (in seconds) at which to sync changes
    # slave.unison.repeat = 5 # Default: 1

    #
    # end of unison
    #

    slave.vm.synced_folder "provisioning", '/vagrant'

    slave.vm.synced_folder ".",
                           "/home/vagrant/whph-website",
                           type: "rsync",                         
                           :rsync__args => ["--verbose", "--archive", "--delete", "-z", "--links", "--no-owner", "--no-group"],
                           rsync__exclude: ['.stack-work',
                                            '_cache',
                                            '_site',
                                            "_tmp",
                                            "bin",
                                            "src",
                                            "w7w/src"]



    slave.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.name ="slave"
      # vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end



    slave.ssh.forward_agent = true

    config.vm.network :private_network, ip: "192.168.30.100"

    slave.vm.hostname = "whph-slave"

    if defined?(VagrantPlugins::HostsUpdater)

      # Pass the found host names to the hostsupdater plugin so it can perform magic.
      slave.hostsupdater.aliases = ["work-hard.test"]
      slave.hostsupdater.remove_on_suspend = true
    end

    #
    #
    # PROVISIONING
    #
    #

    slave.vm.provision "shell", path: "provisioning/prelude.sh"

    # slave.vm.provision :host_shell do |host_shell|
    #   host_shell.inline = 'vagrant unison-sync-once'
    # end

    slave.vm.provision "shell", privileged: false, path: "provisioning/user-specific.sh"
    slave.vm.provision "shell", path: "provisioning/whph-common-setup.sh", privileged: false
    slave.vm.provision "shell", path: "provisioning/whph-slave-setup.sh", privileged: false

  end
end
