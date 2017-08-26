node['chef_nginx']['sites'].each do |sites|
  sites['apps'].keys.each do |site|
    chef_nginx_add_rails_sites site do
      root_path     sites['root_path']
      user          sites['user']
      projects_path sites['projects_path']
      ssl_exist     sites['apps'][site]['ssl_exist']
      cert_path     sites['apps'][site]['cert_path']
      action :add
    end
  end
end