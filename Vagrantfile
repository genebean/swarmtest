Vagrant.configure("2") do |config|
  config.vm.box = "genebean/centos-7-puppet5"

  (1..3).each do |n|
    config.vm.define "docker#{n}" do |docker|
      docker.vm.hostname = "docker#{n}"
      docker.vm.network "private_network", ip: "172.16.0.#{n + 10}"
      docker.vm.network "forwarded_port", guest: 80, host: "808#{n}"

      if File.exists?('./manager-token')
        docker.vm.provision "shell", inline: <<-SCRIPT
          echo "Creating the swarm_manager_token fact..."
          mkdir -p /etc/puppetlabs/facter/facts.d
          echo "swarm_manager_token=$(cat /vagrant/manager-token)" > /etc/puppetlabs/facter/facts.d/swarm_manager_token.txt
        SCRIPT
      end

      docker.vm.provision "shell", inline: <<-SCRIPT
        puppet module install puppetlabs-docker
        puppet apply /vagrant/host.pp
      SCRIPT
    end
  end
end
