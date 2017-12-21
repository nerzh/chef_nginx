require_relative '../libraries/helpers'

actions :add
default_action :add

property :name,          String, name_attribute: true
property :root_path,     String, required: true
property :user,          String, required: true
property :projects_path, String, required: true
property :ssl_exist,     [String, TrueClass, FalseClass], default: false
property :cert_path,     [String, NilClass], default: nil
property :current_path,  [String, NilClass], default: nil
property :socket_path,   [String, NilClass], default: nil
property :static_path,   [String, NilClass], default: nil
property :add_adminer,   [String, TrueClass, FalseClass], default: false

action :add do
  app_dir        = "/#{new_resource.root_path}/#{new_resource.user}/#{new_resource.projects_path}/#{new_resource.name}"
  socket_path    = "/#{app_dir}/shared/shared/puma.sock"
  static_path    = "/#{app_dir}/public"
  domain         = new_resource.name
  dir_secret_key = "/root/#{domain}_chef_secret_key"

  secret         = Chef::EncryptedDataBagItem.load_secret(dir_secret_key)
  ssl_data       = Chef::EncryptedDataBagItem.load("chef_nginx_ssl_certificates", "#{new_resource.name}", secret) if new_resource.ssl_exist.to_s == 'true'
  
  app_dir        = new_resource.current_path if new_resource.current_path
  socket_path    = new_resource.socket_path  if new_resource.socket_path
  static_path    = new_resource.static_path  if new_resource.static_path

  template "/etc/nginx/sites-enabled/#{new_resource.name}.conf" do
    source 'rails_site.conf.erb'
    owner  'root'
    group  'root'
    mode   '0644'
    variables props: {
      "name" => new_resource.name, 
      "app_dir" => app_dir,
      "socket_path" => socket_path,
      "static_path" => static_path,
      "ssl_exist" => (new_resource.ssl_exist.to_s == 'true'),
      "crt" => "ssl_certificate /etc/nginx/ssl/#{new_resource.name}.crt;",
      "key" => "ssl_certificate_key /etc/nginx/ssl/#{new_resource.name}.key;",
      "add_adminer" => (new_resource.add_adminer.to_s == 'true')
    }
    action :create
  end

  if (new_resource.add_adminer.to_s == 'true')
    template "/etc/nginx/fastcgi.conf" do
      source 'fastcgi.conf.erb'
      owner  'root'
      group  'root'
      mode   '0644'
      action :create
    end
  end

  if new_resource.ssl_exist.to_s == 'true'
    directory '/etc/nginx/ssl' do
      owner 'root'
      group 'root'
      mode  '0755'
      recursive true
      action :create
    end

    file "/etc/nginx/ssl/#{new_resource.name}.key" do
      content "#{ssl_data['key']}"
      mode '0644'
      owner 'root'
      group 'root'
    end

    file "/etc/nginx/ssl/#{new_resource.name}.crt" do
      content "#{ssl_data['cert']}"
      mode '0644'
      owner 'root'
      group 'root'
    end
  end

  execute 'restart-nginx' do
    command "bash -lc 'service nginx restart'"
  end
end

action_class do
  include ChefNginxHelper
end