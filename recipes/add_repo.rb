chef_nginx_add_repo 'Add ppa nginx repository' do
  # ppa       node['chef_nginx']['repo']['ppa']
  keyserver node['chef_nginx']['repo']['keyserver']
  action :add
end