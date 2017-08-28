node['chef_nginx']['sites'].each do |sites|
  sites['apps'].keys.each do |site|
    chef_nginx_add_rails_sites site do
      sites['root_path']     ? root_path sites['root_path']         : root_path node['chef_nginx']['root_path']
      sites['projects_path'] ? projects_path sites['projects_path'] : projects_path node['chef_nginx']['projects_path']
      user          sites['user']
      ssl_exist     sites['apps'][site]['ssl_exist']
      cert_path     sites['apps'][site]['cert_path']    if sites['apps'][site]['cert_path']
      current_path  sites['apps'][site]['current_path'] if sites['apps'][site]['current_path']
      socket_path   sites['apps'][site]['socket_path']  if sites['apps'][site]['socket_path']
      static_path   sites['apps'][site]['static_path']  if sites['apps'][site]['static_path']
      action :add
    end
  end
end