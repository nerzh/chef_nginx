chef_nginx_install "Install nginx #{node['chef_nginx']['version']}" do
  version node['chef_nginx']['version'] unless node['chef_nginx']['version'] == 'latest'
  action :install
end