source "https://supermarket.chef.io"

cookbook 'fail2ban'
cookbook 'git'

Dir['cookbooks/**'].each do |path|
  cookbook File.basename(path), path: path
end
