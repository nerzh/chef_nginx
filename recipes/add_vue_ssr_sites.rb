node['chef_nginx']['sites'].each do |sites|
  sites['apps'].keys.each do |site|
    chef_nginx_add_vue_ssr_sites(site) do
      sites['root_path']     ? root_path(sites['root_path'])         : root_path(node['chef_nginx']['root_path'])
      sites['projects_path'] ? projects_path(sites['projects_path']) : projects_path(node['chef_nginx']['projects_path'])
      user          sites['user']
      ssl_exist     sites['apps'][site]['ssl_exist']
      cert_path     sites['apps'][site]['cert_path']    if sites['apps'][site]['cert_path']
      current_path  sites['apps'][site]['current_path'] if sites['apps'][site]['current_path']
      nodejs_express_port  sites['apps'][site]['nodejs_express_port'] if sites['apps'][site]['nodejs_express_port']
      static_path   sites['apps'][site]['static_path']  if sites['apps'][site]['static_path']
      if sites['add_adminer_config_to_all_sites'].to_s == 'true' or sites['apps'][site]['add_adminer_config'].to_s == 'true'
        add_adminer true
      end
      action :add
    end
  end
end