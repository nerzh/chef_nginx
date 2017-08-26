require_relative '../libraries/helpers'

actions :add
default_action :add

property :name,          String, name_attribute: true
property :root_path,     String
property :user,          String, required: true
property :projects_path, String
property :ssl_exist,     [String, TrueClass, FalseClass], default: false
property :cert_path,     String

action :add do
  app_dir = "/#{new_resource.root_path}/#{new_resource.user}/#{new_resource.projects_path}/#{new_resource.name}"
  
  execute "restart-nginx" do
    command "bash -lc 'service nginx restart'"
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

  notifies :run, "execute[restart-nginx]", :immediately
end

action_class do
  include ChefNginxHelper
end