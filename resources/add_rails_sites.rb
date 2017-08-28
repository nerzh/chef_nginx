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

action :add do
  app_dir     = "/#{new_resource.root_path}/#{new_resource.user}/#{new_resource.projects_path}/#{new_resource.name}"
  socket_path = "/#{app_dir}/shared/shared/puma.sock"
  static_path = "/#{app_dir}/public"
  
  app_dir     = new_resource.current_path if new_resource.current_path
  socket_path = new_resource.socket_path  if new_resource.socket_path
  static_path = new_resource.static_path  if new_resource.static_path
  
  service "nginx" do
    action :nothing
  end

  directory app_dir do
    owner new_resource.user
    group new_resource.user
    mode  '0755'
    recursive true
    action :create
  end

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
      "ssl_exist" => new_resource.ssl_exist,
      "crt" => "ssl_certificate /etc/nginx/ssl/#{new_resource.name}.crt;",
      "key" => "ssl_certificate_key /etc/nginx/ssl/#{new_resource.name}.key;"
    }
    action :create
  end

  if new_resource.ssl_exist
    directory '/etc/nginx/ssl' do
      owner 'root'
      group 'root'
      mode  '0755'
      recursive true
      action :create
    end

    template "/etc/nginx/ssl/#{new_resource.name}.key" do
      cookbook 'chef_nginx_ssl_certificates'
      source "#{new_resource.name}.key.erb"
      owner  'root'
      group  'root'
      mode   '0644'
      action :create
    end

    template "/etc/nginx/ssl/#{new_resource.name}.crt" do
      cookbook 'chef_nginx_ssl_certificates'
      source "#{new_resource.name}.crt.erb"
      owner  'root'
      group  'root'
      mode   '0644'
      action :create
    end
  end

  notifies :restart, "service[nginx]", :immediately
end

action_class do
  include ChefNginxHelper
end