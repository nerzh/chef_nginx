actions :add
default_action :add

property :name, String, name_attribute: true

action :add do
  template '/etc/nginx/nginx.conf' do
    source 'nginx.conf.erb'
    owner  'root'
    group  'root'
    mode   '0644'
  end

  directory '/etc/nginx/sites-enabled' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end