# -*- mode: ruby -*-
# vi: set ft=ruby :

require "dotenv"
Dotenv.load

Vagrant.configure("2") do |config|
  config.vm.provision :chef_solo do |chef|
    chef.roles_path = "roles"
    chef.add_role("server")
  end

  config.vm.provision :docker do |d|
    d.pull_images "redis"
    d.pull_images "mongo"
    d.pull_images "ermaker/mshard_server"
    d.pull_images "ermaker/honeypot"
    d.pull_images "nginx"

    d.run "redis",
      cmd: "redis-server --appendonly yes",
      args: [
        "-v /opt/redis/data:/data"
      ].join(" ")
    d.run "mongo",
      cmd: "--smallfiles",
      args: [
        "-v /opt/mongo/data/db:/data/db"
      ].join(" ")
    d.run "mshard",
      image: "ermaker/mshard_server",
      args: [
        "--link redis:redis",
        *ENV.select {|k,v| k =~ /^MSHARD_/}.map do |k,v|
          "-e " + k[/^MSHARD_(.*)$/, 1] + "=" + v
        end
      ].join(" ")
    d.run "honeypot-db-setup",
      image: "ermaker/honeypot",
      cmd: "foreman run rake db:setup",
      daemonize: false,
      restart: "no",
      args: [
        "--rm",
        "--link mongo:mongo",
        "--link mshard:mshard",
        *ENV.select {|k,v| k =~ /^HONEYPOT_/}.map do |k,v|
          "-e " + k[/^HONEYPOT_(.*)$/, 1] + "=" + v
        end
      ].join(" ")
    d.run "honeypot",
      image: "ermaker/honeypot",
      args: [
        "--link mongo:mongo",
        "--link mshard:mshard",
        *ENV.select {|k,v| k =~ /^HONEYPOT_/}.map do |k,v|
          "-e " + k[/^HONEYPOT_(.*)$/, 1] + "=" + v
        end
      ].join(" ")
    d.run "nginx", args: [
      "-p 80:80",
      "-v /vagrant/html/:/usr/share/nginx/html:ro",
      "-v /vagrant/nginx.conf/conf.d/proxy.conf:/etc/nginx/conf.d/proxy.conf:ro",
      "-v /vagrant/nginx.conf/conf.d/proxy/:/etc/nginx/conf.d/proxy:ro",
      "--link mshard:mshard",
      "--link honeypot:honeypot"
    ].join(" ")
  end

  config.vm.provider :aws do |aws,override|
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    aws.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
    aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]

    aws.keypair_name = "default"
    override.ssh.private_key_path = "default.pem"

    aws.ami = "ami-20b6aa21"
    override.ssh.username = "ubuntu"

    aws.region = "ap-northeast-1"
    aws.instance_type = "t2.micro"
    aws.security_groups = "default_instance"
    aws.tags = {Name: "Test with Vagrant"}
    aws.elastic_ip = ENV['AWS_ELASTIC_IP']
    override.vm.hostname = ENV['AWS_HOSTNAME']
  end
end
