VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "trusty64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.provision :docker 

  config.vm.provision :shell, :inline => <<-EOT
    apt-get install -y curl git vim
    apt-get install -y squid-deb-proxy
  EOT
end
