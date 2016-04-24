# -*- mode: ruby -*-
# vi: set ft=ruby :

require "dotenv"
Dotenv.load

Vagrant.configure("2") do |config|
  config.vm.provision :docker

  config.vm.provision :shell, inline: <<-EOC
    test -e /usr/local/bin/docker-compose || \\
    curl -sSL https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` \\
      | sudo tee /usr/local/bin/docker-compose > /dev/null
    sudo chmod +x /usr/local/bin/docker-compose
    test -e /etc/bash_completion.d/docker-compose || \\
    curl -sSL https://raw.githubusercontent.com/docker/compose/$(docker-compose --version | awk 'NR==1{print $NF}')/contrib/completion/bash/docker-compose \\
      | sudo tee /etc/bash_completion.d/docker-compose > /dev/null
  EOC

  config.vm.provision :shell, inline: <<-EOC
    cd /vagrant/service
    ./mkdirs.sh
    docker-compose pull
    docker-compose down
    # docker-compose run --rm honeypot foreman run rake db:setup
    docker-compose up -d
  EOC

  config.vm.provider :aws do |aws,override|
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    aws.access_key_id = ENV["ACCESS_KEY_ID"]
    aws.secret_access_key = ENV["SECRET_ACCESS_KEY"]

    aws.keypair_name = "default"
    override.ssh.private_key_path = "default.pem"

    aws.ami = "ami-09dc1267"
    override.ssh.username = "ubuntu"

    aws.region = "ap-northeast-2"
    aws.instance_type = "t2.nano"
    aws.security_groups = "default_"
    aws.tags = {Name: "Default"}
    aws.elastic_ip = ENV['ELASTIC_IP']
    override.vm.hostname = ENV['HOSTNAME']
  end
end
